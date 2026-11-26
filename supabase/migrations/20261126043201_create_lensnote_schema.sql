-- 1. Enable pgvector, and say exactly where to install it (the "extensions" schema)
create extension if not exists vector with schema extensions;

-- 2. Topics table (subject folders)
create table public.topics (
  id uuid default gen_random_uuid() primary key,                          -- unique id, auto-generated
  user_id uuid references auth.users(id) on delete cascade not null,      -- owner; deleting the user deletes their topics
  title text not null,                                                    -- folder name
  created_at timestamptz default now() not null,                          -- when it was created
  unique (user_id, title)                                                 -- no duplicate topic names per user
);

-- 3. Notes table (cleaned Markdown documents)
create table public.notes (
  id uuid default gen_random_uuid() primary key,                          -- unique id
  user_id uuid references auth.users(id) on delete cascade not null,      -- owner
  topic_id uuid references public.topics(id) on delete cascade not null,  -- which topic folder it belongs to
  title text not null,                                                    -- note title
  content_markdown text not null,                                         -- transcribed Markdown from Gemini
  created_at timestamptz default now() not null                           -- when it was saved
);

-- 4. Note chunks table (RAG vector store)
create table public.note_chunks (
  id bigserial primary key,                                               -- auto-incrementing id
  user_id uuid references auth.users(id) on delete cascade not null,      -- owner (used to scope searches)
  topic_id uuid references public.topics(id) on delete cascade not null,  -- topic, for filtering searches
  note_id uuid references public.notes(id) on delete cascade not null,    -- parent note; deleting the note deletes its chunks
  chunk_index int not null,                                               -- order of the chunk within the note
  content text not null,                                                  -- the chunk's text
  embedding extensions.vector(768) not null                               -- embedding; 768 must match your embedding model
);

-- 5. Indexes
create index idx_topics_user_id on public.topics(user_id);                          -- list a user's topics fast
create index idx_notes_topic_id on public.notes(topic_id);                          -- list a topic's notes fast
create index idx_notes_user_id on public.notes(user_id);                            -- list a user's notes fast
create index idx_note_chunks_user_topic on public.note_chunks(user_id, topic_id);   -- filter chunks by user and topic
create index idx_note_chunks_note_id on public.note_chunks(note_id);                -- speeds up joins and cascade deletes
create index idx_note_chunks_embedding on public.note_chunks
  using hnsw (embedding extensions.vector_cosine_ops);                              -- fast approximate similarity search

-- 6. Row Level Security (blocks the public key; your backend's secret key bypasses it)
alter table public.topics enable row level security;
alter table public.notes enable row level security;
alter table public.note_chunks enable row level security;

-- 7. Vector similarity search function (called from Node with supabase.rpc)
create or replace function public.match_note_chunks (
  query_embedding extensions.vector(768),   -- embedding of the user's question
  match_threshold float,                    -- minimum similarity (0 to 1) to count as a match
  match_count int,                          -- max number of chunks to return
  p_user_id uuid,                           -- only search this user's chunks
  p_topic_id uuid default null              -- optional: limit to one topic
)
returns table (
  id bigint,
  note_id uuid,
  note_title text,
  content text,
  similarity float
)
language sql stable
set search_path = public, extensions        -- lets the function find the vector type and the <=> operator
as $$
  select
    nc.id,
    nc.note_id,
    n.title as note_title,
    nc.content,
    1 - (nc.embedding <=> query_embedding) as similarity    -- cosine distance converted to similarity
  from public.note_chunks nc
  join public.notes n on n.id = nc.note_id
  where nc.user_id = p_user_id
    and (p_topic_id is null or nc.topic_id = p_topic_id)
    and 1 - (nc.embedding <=> query_embedding) > match_threshold
  order by nc.embedding <=> query_embedding               -- closest chunks first
  limit match_count;
$$;

-- 8. Lock down the function: only your backend (service_role) may call it
revoke execute on function public.match_note_chunks(extensions.vector, float, int, uuid, uuid) from public, anon, authenticated;
grant execute on function public.match_note_chunks(extensions.vector, float, int, uuid, uuid) to service_role;
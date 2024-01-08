import { SupabaseClient } from '@supabase/supabase-js';

const supabase = new SupabaseClient(import.meta.env.VITE_SUPABASE_URL, import.meta.env.VITE_SUPABASE_ANON_KEY);

export default supabase;
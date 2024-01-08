import MovieDb from 'moviedb';

const TMDB = MovieDb(import.meta.env.VITE_TMDB_API_KEY);

export default TMDB;

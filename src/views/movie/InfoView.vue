<script setup>
import { defineProps, onMounted, ref } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import TMDB from '@/TMDB';

const route = useRoute();
const movie = ref();

onMounted(() => {
    TMDB.movieInfo({ id: route.params.id, include_video: true }, (err, res) => {
        if (err) {
            console.log(err);
        } else {
            movie.value = res;
            console.log(movie.value);
        }
    });
});

</script>
<template>
    <div class="surface-section">
        <ul class="list-none p-0 m-0">
            <li class="flex align-items-center py-3 px-2 surface-border flex-wrap">
                <div class="text-500 w-6 md:w-2 font-medium">Title</div>
                <div class="text-900 w-full md:w-8 md:flex-order-0 flex-order-1">{{ movie?.title }}</div>
            </li>
            <li class="flex align-items-center py-3 px-2 border-top-1 surface-border flex-wrap">
                <div class="text-500 w-6 md:w-2 font-medium">Genre</div>
                <div class="text-900 w-full md:w-8 md:flex-order-0 flex-order-1">
                    <Chip v-for="genre in movie?.genres" :key="genre.id" :label="genre.name" class="mr-2"/>
                </div>
            </li>
            <li class="flex align-items-center py-3 px-2 border-top-1 surface-border flex-wrap">
                <div class="text-500 w-6 md:w-2 font-medium">Plot</div>
                <div class="text-900 w-full md:w-8 md:flex-order-0 flex-order-1 line-height-3">{{ movie?.overview }}</div>
            </li>
        </ul>
        <div class="video-container">
            <iframe
                v-if="movie?.videos?.results[0]?.key"
                :src="`https://www.youtube.com/embed/${movie?.videos?.results[0]?.key}`"
                width="100%"
                height="315"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen="allowfullscreen"
            ></iframe>
        </div>
    </div>
</template>
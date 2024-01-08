<script setup>
import { ref, onMounted, computed } from 'vue';
import TMDB from '@/TMDB';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

const movie = ref();

const getImageUrl = (path) => {
    return computed(() => {
        return import.meta.env.VITE_TMDB_IMAGE_URL + path;
    });
};

const heroUrl = computed(() => {
    return import.meta.env.VITE_TMDB_IMAGE_URL + movie.value?.backdrop_path;
});
const posterUrl = computed(() => {
    return getImageUrl(movie.value?.poster_path).value;
});

onMounted(() => {
    TMDB.movieInfo({ id: route.params.id }, (err, res) => {
        if (err) {
            console.log(err);
        } else {
            movie.value = res;
            console.log(movie.value);
        }
    });
});

const activeIndex = ref(0);
const nestedRouteItems = ref([
    {
        label: 'Info',
        to: '/movie/' + route.params.id + '/info',
    },
    {
        label: 'Reservation',
        to: '/movie/' + route.params.id + '/reservation',
    },
    {
        label: 'Payment',
        to: '/movie/' + route.params.id + '/payment'
    },
    {
        label: 'Confirmation',
        to: '/movie/' + route.params.id + '/confirmation'
    }
]);

const links = ref([
    {
        id: 'home',
        label: 'Home',
        icon: 'pi pi-fw pi-home',
        to: '/home'
    },
    {
        id: 'movies',
        label: 'Movies',
        to: '/movies'
    },
    {
        id: 'cinemas',
        label: 'Cinemas',
        to: '/cinemas'
    }
]);
</script>

<template>
    <div class="surface-0 flex justify-content-center">
        <div id="home" class="landing-wrapper overflow-hidden relative">
            

            <div id="hero" class="flex p-0 overflow-hidden w-screen justify-content-center align-items-center relative" style="height: 20vh">
                <div class="absolute w-screen h-screen card-overlay"/>
                <div class="absolute mt-5">
                    <div class="flex gap-6">
                        <span class="block text-4xl font-bold text-white">{{ movie?.title }}</span>
                    </div>
                </div>

                <div class="bg-cover bg-center h-screen w-screen" :style="'background-image: url(' + heroUrl + ')'"/>
            </div>

            <div class="grid ml-8">
                <div class="col-3 relative flex flex-column gap-2">
                    <div class="overflow-hidden" style="margin-top: 2rem">
                        <div class="bg-cover bg-center border-round h-30rem w-100 max-w-20rem" :style="'background-image: url(' + posterUrl + ')'"/>
                    </div>

                    <div v-for="seat in 4" class="card flex gap-4 p-3 m-0 min-w-100 justify-content-between">
                        <div id="position" class="bg-white flex align-items-center h-2rem">
                            <p class="text-2xl font-bold">A row 15 col</p>
                        </div>
                        <div id="price">
                            <span class="text-2xl font-bold">$ 15</span>
                        </div>
                    </div>
                </div>
                
                <div class="col-9 p-6 flex flex-column">
                    <TabMenu :model="nestedRouteItems" />
                    <div class="mt-5">
                        <router-view/>
                    </div>
                    
                </div>
            </div>
        </div>
    </div>
    <AppConfig simple />
</template>

<style scoped>
.card-overlay {
    background: rgba(0, 0, 0, 0.8);
}
</style>

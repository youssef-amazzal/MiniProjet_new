<script setup>
import { useLayout } from '@/layout/composables/layout';
import { computed, ref, onMounted } from 'vue';
import AppConfig from '@/layout/AppConfig.vue';
import TMDB from '@/TMDB';
import { useRouter } from 'vue-router';


const { layoutConfig } = useLayout();
const router = useRouter();

const heroMovie = ref();
const movies = ref();
onMounted(() => {
    TMDB.miscNowPlayingMovies({ page: 1, sort_by: 'popularity.desc' }, (err, res) => {
        if (err) {
            console.log(err);
        } else {
            heroMovie.value = res.results[1];
            console.log(res.results.map((movie) => movie.id));
        }
    });

    TMDB.miscNowPlayingMovies({ page: 1 }, (err, res) => {
        if (err) {
            console.log(err);
        } else {
            movies.value = res.results
        }
    });
});


const smoothScroll = (id) => {
    document.querySelector(id).scrollIntoView({
        behavior: 'smooth'
    });
};

const logoUrl = computed(() => {
    return `layout/images/${layoutConfig.darkTheme.value ? 'logo-white' : 'logo-dark'}.svg`;
});

const getImageUrl = (path) => {
    return computed(() => {
        return import.meta.env.VITE_TMDB_IMAGE_URL + path;
    });
};

const heroUrl = computed(() => {
    return import.meta.env.VITE_TMDB_IMAGE_URL + heroMovie.value?.backdrop_path;
});
const posterUrl = computed(() => {
    return getImageUrl(heroMovie.value?.poster_path).value;
});

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

const goToMovie = (movie) => {
    router.push({ name: 'movie', params: { id: movie.id } });
};

</script>

<template>
    <div class="surface-0 flex justify-content-center">
        <div id="home" class="landing-wrapper overflow-hidden relative">
            
            <Toolbar class="bg-transparent border-none align-items-start absolute top-0 z-5 w-screen">
        
                <template #center>
                    <div v-if="!hideTabs" class="flex">
                        <Button 
                            v-for="link in links" 
                            :key="link.label" 
                            text 
                            class="py-2 px-4 m-2 text-white no-underline hover:text-blue-800 border-none"
                            @click="smoothScroll(`#${link.id}`)"
                        >
                            <i :class="[link.icon, 'text-white']" />
                            <span class="p-button-label pointer">{{ link.label }}</span>
                        </Button>
                    </div>
                </template>
        
                <!-- <template #end>
                    <div class="window-buttons">
                        <Button v-for="(button, index) in buttons" :key="index" :class="`transparent border-noround ${button.class}`" @click="button.click">
                            <component :is="button.icon" class="text-color w-1rem h-full" />
                        </Button>
                    </div>
                </template> -->
            </Toolbar>

            <div
                id="hero"
                class="flex flex-column lg:px-8 p-0 overflow-hidden w-screen h-screen justify-content-center align-items-center relative"
            >
                <div class="absolute w-screen h-screen card-overlay"></div>
                <div class="absolute left-0 ml-8">
                    <div class="flex gap-6">
                        <div class="overflow-hidden">
                            <div class="bg-cover bg-center border-round w-13rem" :style="'background-image: url(' + posterUrl + ')'"></div>
                        </div>

                        <section class="w-30rem">
                            <span class="block text-5xl font-bold mb-3 text-white" style="word-wrap: break-word;"> {{ heroMovie?.title }}</span>
                            <p class="text-white text-md mb-5">{{ heroMovie?.overview }}</p>
                            <Button label="Buy Ticket" class="p-button-rounded border-none font-light text-white line-height-2 bg-blue-500"></Button>
                        </section>
                        
                    </div>
                    
                </div>
                
                <div class="bg-cover bg-center h-screen w-screen" :style="'background-image: url(' + heroUrl + ')'"></div>
                    
            </div>

            <div id="movies" class="flex flex-column m-5">
                
                <!-- <Toolbar>
                    <template #start>
                        <div class="flex gap-2">
                            <Dropdown v-model="selectedCity" :options="cities" optionLabel="name" placeholder="Select a City" class="w-full md:w-14rem" />
                            <Dropdown v-model="selectedCity" :options="cities" optionLabel="name" placeholder="Select a City" class="w-full md:w-14rem" />
                            <Dropdown v-model="selectedCity" :options="cities" optionLabel="name" placeholder="Select a City" class="w-full md:w-14rem" />
                        </div>
                    </template>
                
                    <template #end>
                        <span class="p-input-icon-left">
                            <i class="pi pi-search" />
                            <InputText placeholder="Search" />
                        </span>
                    </template>
                </Toolbar> -->

                <h1 class="text-6xl font-bold mb-1">Now Playing</h1>

                <div class="grid mt-4">
                    <div v-for="movie in movies" :key="movie" class="col-2">
                        <div class="cursor-pointer relative" @click="goToMovie(movie)">
                            <div class="absolute top-0 left-0 w-full h-full border-round-lg poster-overlay"></div>
                            <img :src="getImageUrl(movie.poster_path).value" class="w-full h-full border-round-lg" />
                        </div>
                        
                        <div class="flex flex-column align-items-center justify-content-between pt-2 p-3">
                            <div class="flex align-items-center justify-content-center text-center font-normal">
                                {{ movie.title }}
                            </div>
                        </div>
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

.poster-overlay:hover {
    background: rgba(0, 0, 0, 0.5);
}
</style>

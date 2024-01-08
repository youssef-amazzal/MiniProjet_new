<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import supabase from '@/supabase';

// ticket(id serial, id_projection int, id_seatType int, id_user uuid, price float, seat_number int, seat_row int, seat_column int, status varchar)

const projections = ref([]);
const ticket = ref({});

watch(
    () => ticket.value.cinema,
    (cinema) => {
        cinemaProjections.value = projections.value
            .filter((projection) => projection.cinema === cinema)
            .map((projection) => {
                console.log(projection);
                return fomatProjection(projection);
            });
    }
);

const fomatProjection = (projection) => {
    const startTime = new Date(projection.start_time);
    const endTime = new Date(projection.end_time);
    return {
        ...projection,
        startTime: `${startTime.getFullYear()}-${startTime.getMonth() + 1}-${startTime.getDate()} ${startTime.getHours()}:${startTime.getMinutes()}`,
        endTime: `${endTime.getFullYear()}-${endTime.getMonth() + 1}-${endTime.getDate()} ${endTime.getHours()}:${endTime.getMinutes()}`,
    };
};

const cinemas = computed(() => projections.value.map((projection) => projection.cinema).filter((cinema, index, self) => self.findIndex((c) => c.id === cinema.id) === index));

const cinemaProjections = ref([]);

onMounted(async () => {
    const route = useRoute();
    const movieId = route.params.id;
    const { data, error } = await supabase.rpc('get_projections_by_movie', { param_movie_id: movieId, param_with_layout: true });
    if (error) {
        console.error(error);
    } else {
        projections.value = data;
        ticket.value.projection = fomatProjection(data[0]);
        ticket.value.cinema = data[0].cinema;
    }
});
</script>
<template>
    <div class="grid">
        <div class="col-12 flex gap-5 justify-content-center">
            <Dropdown id="Cinema" v-model="ticket.cinema" :options="cinemas" placeholder="Select a Cinema" />
            <Dropdown id="Projection" v-model="ticket.projection" :options="cinemaProjections" optionLabel="startTime" placeholder="Select a Time" />
        </div>
        <div ref="editorCard" class="col-12">
            <div class="editor overflow-auto flex flex-column gap-1 align-items-center surface-800 p-5 h-30rem">
                <div class="screen w-30rem h-2rem border-3 mb-6"></div>
                <div v-for="row in ticket?.projection?.seat_map" :key="row" class="flex cursor-pointer gap-1">
                    <div v-for="column in ticket?.projection?.seat_map[0]" :key="column" :id="row + '_' + column" class="w-2rem h-2rem bg-white border-1 border-400 border-round pointer" @click="addSeatChild(selectedType)"/>
                </div>
            </div>
        </div>
    </div>
</template>

<style>
.editor {
    opacity: 0.8;
    background-image: radial-gradient(var(--surface-500) 0.9500000000000001px, var(--surface-50) 0.9px);
    background-size: 19px 19px;
}
</style>

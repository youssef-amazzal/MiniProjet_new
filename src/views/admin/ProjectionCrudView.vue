<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import { useToast } from 'primevue/usetoast';
import supabase from '@/supabase';
import TMDB from '@/tmdb';

const toast = useToast();
const cinemaId = '99bd76cd-a0bf-4ebb-be55-94791ac9c581';

const projection = ref({});
const projections = ref([]);
const movies = ref([]);
const searchRes = ref([]);
const theaters = ref([]);

const projectionDialog = ref(false);
const deleteProjectionDialog = ref(false);
const deleteProjectionsDialog = ref(false);
const selectedProjections = ref(null);

const dt = ref(null);
const filters = ref({});
const submitted = ref(false);

onBeforeMount(() => {
    initFilters();
});

onMounted(async () => {
    const projectionsResponse = await supabase.rpc('get_projections_by_cinema', { par_cinema_id: cinemaId });
    const theatersResponse = await supabase.rpc('get_theaters_by_cinema', { par_cinema_id: cinemaId });

    if (projectionsResponse.error || theatersResponse.error) {
        toast.add({ severity: 'error', summary: 'Error', detail: 'Failed to fetch data', life: 3000 });
        console.log(projectionsResponse.error);
    } else {
        projections.value = projectionsResponse.data;
        theaters.value = theatersResponse.data;
    }

    const moviesId = projections.value.map((projection) => projection.id_tmdb).filter((value, index, self) => self.indexOf(value) === index);
    for (const movieId of moviesId) {
        TMDB.movieInfo({ id: movieId }, (err, res) => {
            if (err) {
                console.log(err);
            } else {
                movies.value.push(res);
            }
        });
    }
});

const getMovie = (movieId) => {
    return movies.value.find((movie) => movie.id === movieId);
};

// format date to yyyy-mm-dd
const stampToDate = (stamp) => {
    return new Date(stamp).toISOString().split('T')[0];
};

// format date to hh:mm 24h
const stampToTime = (stamp) => {
    const adjustedTime = new Date(stamp).toISOString().split('T')[1].split('.')[0];
    return adjustedTime.substring(0, adjustedTime.lastIndexOf(':'));
};

const stampToDateTime = (stamp) => {
    const date = new Date(stamp).toISOString().split('T')[0];
    const time = new Date(stamp).toISOString().split('T')[1].split('.')[0];
    return date + ' ' + time.substring(0, time.lastIndexOf(':'));
};

const dateToStamp = (date) => {
    // date is a formatted string yyyy-mm-dd hh:mm
    return new Date(date);
};

const onMovieFilter = (event) => {
    TMDB.searchMovie({ query: event.value }, (err, res) => {
        if (err) {
            console.log(err);
        } else {
            searchRes.value = res.results;
        }
    });
};

const onMovieSelect = () => {
    projection.value.id_tmdb = projection.value.movie.id;
    console.log(projection.value.movie);
};

// const formatCurrency = (value) => {
//     return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
// };

const openNew = () => {
    projection.value = {};
    submitted.value = false;
    projectionDialog.value = true;
};

const hideDialog = () => {
    projectionDialog.value = false;
    submitted.value = false;
};

/*
type projection_by_cinema as (
    id int,
    id_movie int,
    id_tmdb INT,
    start_time timestamp,
    end_time timestamp,
    theater theater,
    layout layout,
    revenue FLOAT,
    tickets_count INT,
    seats_count INT
);
*/
// FUNCTION update_projection(param_id INT, param_id_movie INT, param_id_tmdb INT, param_id_theater INT, param_id_layout INT, param_start_time TIMESTAMP, param_end_time TIMESTAMP)
const saveprojection = async () => {
    submitted.value = true;
    if (projection.value.id_tmdb && projection.value.theater && projection.value.start_time_formatted && projection.value.end_time_formatted) {
        console.log(projection.value.start_time_formatted);
        projection.value.start_time = new Date(new Date(dateToStamp(projection.value.start_time_formatted)).setHours(dateToStamp(projection.value.start_time_formatted).getHours() + 1));
        console.log(projection.value.start_time);
        projection.value.end_time = new Date(new Date(dateToStamp(projection.value.end_time_formatted)).setHours(dateToStamp(projection.value.end_time_formatted).getHours() + 1));

        if (projection.value.id) {
            const { data, error } = await supabase.rpc('update_projection', {
                param_id: projection.value.id,
                param_id_movie: projection.value.id_movie,
                param_id_tmdb: projection.value.id_tmdb,
                param_id_theater: projection.value.theater.id,
                param_id_layout: projection.value.layout.id,
                param_start_time: projection.value.start_time,
                param_end_time: projection.value.end_time
            });
            if (error) {
                toast.add({ severity: 'error', summary: 'Error', detail: 'Failed to update projection', life: 3000 });
                console.log(error);
            } else {
                projections.value[findIndexById(projection.value.id)] = projection.value;
                toast.add({ severity: 'success', summary: 'Successful', detail: 'projection Updated', life: 3000 });
            }
        } else {
            // FUNCTION save_projection(param_id_movie INT, param_id_tmdb INT, param_id_theater INT, param_id_layout INT, param_start_time TIMESTAMP, param_end_time TIMESTAMP)
            const { data, error } = await supabase.rpc('save_projection', {
                param_id_movie: null,
                param_id_tmdb: projection.value.id_tmdb,
                param_id_theater: projection.value.theater.id,
                param_id_layout: projection.value.theater.id_layout,
                param_start_time: projection.value.start_time,
                param_end_time: projection.value.end_time
            });
            const id = data;
            if (error) {
                toast.add({ severity: 'error', summary: 'Error', detail: 'Failed to create projection', life: 3000 });
                console.log(error);
            } else {
                projection.value.id = id;
                projection.value.revenue = 0;
                projection.value.tickets_count = 0;
                const { data, error } = await supabase.rpc('get_seats_count', { param_layout_id: projection.value.theater.id_layout });
                if (error) {
                    toast.add({ severity: 'error', summary: 'Error', detail: 'Failed to fetch seats count', life: 3000 });
                    console.log(error);
                } else {
                    projection.value.seats_count = data;
                }
                projections.value.push(projection.value);
                toast.add({ severity: 'success', summary: 'Successful', detail: 'projection Created', life: 3000 });
            }
        }
        projectionDialog.value = false;
        projection.value = {};
    }
};

const editprojection = (editprojection) => {
    projection.value = { ...editprojection };
    projection.value.movie = getMovie(projection.value.id_tmdb);
    projection.value.start_time_formatted = stampToDateTime(projection.value.start_time);
    projection.value.end_time_formatted = stampToDateTime(projection.value.end_time);
    console.log(projection.value.movie);
    projectionDialog.value = true;
};

const confirmDeleteprojection = (editprojection) => {
    projection.value = editprojection;
    deleteProjectionDialog.value = true;
};

const deleteprojection = async () => {
    //FUNCTION delete_projection(param_projection_id INT)
    const { data, error } = await supabase.rpc('delete_projection', { param_projection_id: projection.value.id });
    if (error) {
        toast.add({ severity: 'error', summary: 'Error', detail: 'Failed to delete projection', life: 3000 });
        console.log(error);
    } else {
        projections.value = projections.value.filter((val) => val.id !== projection.value.id);
        deleteProjectionDialog.value = false;
        projection.value = {};
        toast.add({ severity: 'success', summary: 'Successful', detail: 'projection Deleted', life: 3000 });
    }
};

const findIndexById = (id) => {
    let index = -1;
    for (let i = 0; i < projections.value.length; i++) {
        if (projections.value[i].id === id) {
            index = i;
            break;
        }
    }
    return index;
};

const exportCSV = () => {
    dt.value.exportCSV();
};

const confirmDeleteSelected = () => {
    deleteProjectionsDialog.value = true;
};

const deleteselectedProjections = () => {
    projections.value = projections.value.filter((val) => !selectedProjections.value.includes(val));
    deleteProjectionsDialog.value = false;
    selectedProjections.value = null;
    toast.add({ severity: 'success', summary: 'Successful', detail: 'projections Deleted', life: 3000 });
};

const initFilters = () => {
    filters.value = {
        global: { value: null, matchMode: FilterMatchMode.CONTAINS }
    };
};

/*
type projection_by_cinema as (
    id int,
    id_movie int,
    id_tmdb INT,
    start_time timestamp,
    end_time timestamp,
    theater theater,
    layout layout,
    revenue FLOAT,
    tickets_count INT,
    seats_count INT
);
*/
</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <Toast />
                <Toolbar class="mb-4">
                    <template v-slot:start>
                        <div class="my-2">
                            <Button label="New" icon="pi pi-plus" class="p-button-success mr-2" @click="openNew" />
                            <Button label="Delete" icon="pi pi-trash" class="p-button-danger" @click="confirmDeleteSelected" :disabled="!selectedProjections || !selectedProjections.length" />
                        </div>
                    </template>

                    <!-- <template v-slot:end>
                        <FileUpload mode="basic" accept="image/*" :maxFileSize="1000000" label="Import" chooseLabel="Import" class="mr-2 inline-block" />
                        <Button label="Export" icon="pi pi-upload" class="p-button-help" @click="exportCSV($event)" />
                    </template> -->
                </Toolbar>

                <DataTable
                    ref="dt"
                    class="border-1 border-gray-200 border-round-lg"
                    :value="projections"
                    v-model:selection="selectedProjections"
                    dataKey="id"
                    :paginator="true"
                    :rows="10"
                    :filters="filters"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Showing {first} to {last} of {totalRecords} projections"
                    responsiveLayout="scroll"
                >
                    <!-- <template #header>
                        <div class="flex flex-column md:flex-row md:justify-content-between md:align-items-center">
                            <h5 class="m-0">Manage projections</h5>
                            <span class="block mt-2 md:mt-0 p-input-icon-left">
                                <i class="pi pi-search" />
                                <InputText v-model="filters['global'].value" placeholder="Search..." />
                            </span>
                        </div>
                    </template> -->

                    <Column selectionMode="multiple" headerStyle="width: 3rem"></Column>
                    <Column field="id" header="ID" :sortable="true" headerStyle="width:5%; min-width:5rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">ID</span>
                            {{ slotProps.data.id }}
                        </template>
                    </Column>
                    <Column field="start_time" header="Date" :sortable="true" headerStyle="width:10%; min-width:8rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">Date</span>
                            {{ stampToDate(slotProps.data.start_time) }}
                        </template>
                    </Column>
                    <Column field="start_time" header="Start Time" :sortable="true" headerStyle="width:14%; min-width:5rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">Start Time</span>
                            {{ stampToTime(slotProps.data.start_time) }}
                        </template>
                    </Column>
                    <Column field="end_time" header="End Time" :sortable="true" headerStyle="width:14%; min-width:5rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">End Time</span>
                            {{ stampToTime(slotProps.data.end_time) }}
                        </template>
                    </Column>
                    <Column field="id_tmdb" header="Movie" :sortable="true" headerStyle="width:14%; min-width:15rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">Movie ID</span>
                            {{ slotProps.data.movie?.title ? slotProps.data.movie.title : getMovie(slotProps.data.id_tmdb)?.title }}
                        </template>
                    </Column>
                    <Column field="room" header="Room" :sortable="true" headerStyle="width:14%; min-width:10rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">Room</span>
                            {{ slotProps.data.theater.name }}
                        </template>
                    </Column>
                    <Column field="revenue" header="Revenue" :sortable="true" headerStyle="width:5%; min-width:5rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">Revenue</span>
                            {{ slotProps.data.revenue }}
                        </template>
                    </Column>

                    <Column field="seats_count" header="Availability" :sortable="true" headerStyle="width:14%; min-width:5rem;">
                        <template #body="slotProps">
                            <span class="p-column-title">Seats Count</span>
                            {{ slotProps.data.tickets_count + '/' + slotProps.data.seats_count }}
                        </template>
                    </Column>
                    <Column headerStyle="min-width:10rem;">
                        <template #body="slotProps">
                            <Button icon="pi pi-pencil" class="p-button-rounded p-button-success mr-2" @click="editprojection(slotProps.data)" />
                            <Button icon="pi pi-trash" class="p-button-rounded p-button-warning mt-2" @click="confirmDeleteprojection(slotProps.data)" />
                        </template>
                    </Column>
                </DataTable>

                <Dialog v-model:visible="projectionDialog" :style="{ width: '450px' }" header="Projection Details" :modal="true" class="p-fluid">
                    <div class="field">
                        <label for="movie">Movie</label>
                        <Dropdown v-model="projection.movie" :options="searchRes" filter optionLabel="title" placeholder="Search by title" class="w-full max-w-full" @filter="onMovieFilter" @change="onMovieSelect" />
                        <small class="p-invalid" v-if="submitted && !projection.movie">Movie is required.</small>
                    </div>

                    <div class="field">
                        <label for="Theater">Theater</label>
                        <Dropdown id="Theater" v-model="projection.theater" :options="theaters" optionLabel="name" placeholder="Select a Theater" />
                        <small class="p-invalid" v-if="submitted && !projection.theater">Theater is required.</small>
                    </div>

                    <div class="formgrid grid">
                        <div class="field col">
                            <label for="startDate">Start Time</label>
                            <Calendar id="startTime" v-model="projection.start_time_formatted" showTime hourFormat="24" dateFormat="yy-mm-dd" />
                            <small class="p-invalid" v-if="submitted && !projection.start_time_formatted">Start Time is required.</small>
                        </div>
                        <div class="field col">
                            <label for="endDate">End Time</label>
                            <Calendar id="endTime" v-model="projection.end_time_formatted" showTime hourFormat="24" dateFormat="yy-mm-dd" />
                            <small class="p-invalid" v-if="submitted && !projection.end_time_formatted">End Time is required.</small>
                        </div>
                    </div>
                    <template #footer>
                        <Button label="Cancel" icon="pi pi-times" class="p-button-text" @click="hideDialog" />
                        <Button label="Save" icon="pi pi-check" class="p-button-text" @click="saveprojection" />
                    </template>
                </Dialog>

                <Dialog v-model:visible="deleteProjectionDialog" :style="{ width: '450px' }" header="Confirm" :modal="true">
                    <div class="flex align-items-center justify-content-center">
                        <i class="pi pi-exclamation-triangle mr-3" style="font-size: 2rem" />
                        <span v-if="projection"
                            >Are you sure you want to delete <b>{{ projection.name }}</b
                            >?</span
                        >
                    </div>
                    <template #footer>
                        <Button label="No" icon="pi pi-times" class="p-button-text" @click="deleteProjectionDialog = false" />
                        <Button label="Yes" icon="pi pi-check" class="p-button-text" @click="deleteprojection" />
                    </template>
                </Dialog>

                <Dialog v-model:visible="deleteProjectionsDialog" :style="{ width: '450px' }" header="Confirm" :modal="true">
                    <div class="flex align-items-center justify-content-center">
                        <i class="pi pi-exclamation-triangle mr-3" style="font-size: 2rem" />
                        <span v-if="projection">Are you sure you want to delete the selected projections?</span>
                    </div>
                    <template #footer>
                        <Button label="No" icon="pi pi-times" class="p-button-text" @click="deleteProjectionsDialog = false" />
                        <Button label="Yes" icon="pi pi-check" class="p-button-text" @click="deleteselectedProjections" />
                    </template>
                </Dialog>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss"></style>

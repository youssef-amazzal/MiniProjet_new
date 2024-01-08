<script setup>
import { ref, onMounted } from 'vue';

const roomImg =
    'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.gannett-cdn.com%2Fpresto%2F2019%2F12%2F31%2FPIND%2F603e8fbe-1d25-4310-a985-48ac553793a4-TAS_6073.jpg%3Fcrop%3D3007%2C1691%2Cx0%2Cy317%26width%3D3007%26height%3D1691%26format%3Dpjpg%26auto%3Dwebp&f=1&nofb=1&ipt=73760d63cca8228d8b5904c180cbc48302895c3e97eb07c056a25cfaaac3cba5&ipo=images';

const Types = {
    standard: 'standard',
    vip: 'vip',
    '3d': '3D'
};

const statuses = {
    available: {
        name: 'Available',
        icon: 'pi pi-check',
        severity: 'success'
    },
    occupied: {
        name: 'Occupied',
        icon: 'pi pi-exclamation-triangle',
        severity: 'danger'
    },
    maintenance: {
        name: 'Maintenance',
        icon: 'pi pi-times',
        severity: 'warning'
    },
    cleaning: {
        name: 'Cleaning',
        icon: 'pi pi-refresh',
        severity: 'info'
    }
};

const features = {
    wifi: {
        name: 'Wifi',
        icon: 'pi pi-wifi'
    },
    accessibility: {
        name: 'Accessibility',
        icon: 'pi pi-user'
    },
    '3d': {
        name: '3D',
        icon: 'pi pi-video'
    },
    '4k': {
        name: '4K',
        icon: 'pi pi-image'
    },
    food: {
        name: 'Food',
        icon: 'pi pi-shopping-cart'
    },
    drinks: {
        name: 'Drinks',
        icon: 'pi pi-cocktail'
    },
    imax: {
        name: 'IMAX',
        icon: 'pi pi-video'
    }
};
const rooms = [
    {
        id: 1,
        name: 'Room 1',
        type: Types.standard,
        status: statuses.available,
        features: [features.wifi, features.accessibility],
        capacity: 54
    },
    {
        id: 2,
        name: 'Room 2',
        type: Types.standard,
        status: statuses.available,
        features: [features.wifi, features.accessibility, features['3d']],
        capacity: 54
    }
];

const cardMenu = {
    edit: {
        label: 'Edit',
        icon: 'pi pi-pencil'
    },
    delete: {
        label: 'Delete',
        icon: 'pi pi-trash'
    },
    details: {
        label: 'Details',
        icon: 'pi pi-info-circle'
    },
    disable: {
        label: 'Disable',
        icon: 'pi pi-ban'
    }
};

const dataviewValue = ref(null);
const layout = ref('grid');
const sortOrder = ref(null);
const sortField = ref(null);


onMounted(() => {
    dataviewValue.value = rooms;
});


const menuRef = ref(null);

const toggle = () => {
    menuRef.value.toggle(event);
};

const breadcrumbItems = ref([{ label: 'Rooms' }, { label: 'Room 1' }]);
</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h5>Rooms</h5>
                <Breadcrumb :home="breadcrumbHome" :model="breadcrumbItems" />
                <DataView :value="dataviewValue" :layout="layout" :paginator="true" :rows="9" :sortOrder="sortOrder" :sortField="sortField">
                    <!-- <template #header>
                        <div class="grid grid-nogutter">
                            <div class="col-6 text-left">
                                <Dropdown v-model="sortKey" :options="sortOptions" optionLabel="label" placeholder="Sort By Price" @change="onSortChange($event)" />
                            </div>
                            <div class="col-6 text-right">
                                <DataViewLayoutOptions v-model="layout" />
                            </div>
                        </div>
                    </template> -->

                    <template #grid="slotProps">
                        <div class="col-12 md:col-4">
                            <div class="card m-3 p-0 border-1 surface-border relative">
                                <Button size="small" class="absolute top-0 right-0 text-white m-2 p-2 border-circle p-button-text" @click="toggle">
                                    <i class="pi pi-ellipsis-v text-2xl"></i>
                                </Button>
                                <Menu id="config_menu" ref="menuRef" :model="cardMenu" :popup="true" />
                                <img :src="roomImg" :alt="slotProps.data.name" class="w-full border-round-top-xl" />

                                <div class="flex align-items-center justify-content-between pt-2 p-3">
                                    <div class="flex align-items-center">
                                        <span class="font-semibold">{{ slotProps.data.name }}</span>
                                    </div>
                                    <div class="flex gap-2">
                                        <Tag :icon="slotProps.data.status.icon" :severity="slotProps.data.status.severity" :value="slotProps.data.status.name"></Tag>
                                        <Tag :value="slotProps.data.type"></Tag>
                                    </div>
                                </div>

                                <div class="flex flex-wrap gap-2 p-3">
                                    <div 
                                        v-for="feature in slotProps.data.features" 
                                        :key="feature.name"
                                        class="bg-gray-100 rounded-full flex items-center justify-center p-2"
                                    >
                                        <i :class="feature.icon"></i>

                                    </div>

                                </div>
                            </div>
                        </div>
                    </template>
                </DataView>
            </div>
        </div>
    </div>
</template>

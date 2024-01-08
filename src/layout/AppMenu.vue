<script setup>
import { ref } from 'vue';

import AppMenuItem from './AppMenuItem.vue';

const model = ref([
    // {
    //     label: 'Home',
    //     items: [{ label: 'Dashboard', icon: 'pi pi-fw pi-home', to: '/' }]
    // },
    {
        label: 'Management',
        items: [
            {label: 'Projections', icon: 'pi pi-fw pi-calendar', to: '/projections'},
            {label: 'Rooms', icon: 'pi pi-fw pi-map-marker', to: '/rooms'},
            {label: 'Movies', icon: 'pi pi-fw pi-video', to: '#'},
        ]
    },    
]);
</script>

<template>
    <ul class="layout-menu">
        <template v-for="(item, i) in model" :key="item">
            <app-menu-item v-if="!item.separator" :item="item" :index="i"></app-menu-item>
            <li v-if="item.separator" class="menu-separator"></li>
        </template>
    </ul>
</template>

<style lang="scss" scoped></style>

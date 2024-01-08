<script setup>
import { ref } from 'vue';
// import {useAppStore} from '@/stores/AppStore'
// import {useSettingsStore} from '@/stores/SettingsStore'

// const {view} = useAppStore()
// const {theme} = useSettingsStore()

const items = ref([
    {
        id: 1,
        label: 'Home',
        icon: 'pi pi-fw pi-home',
        to: '/home'
    },
    {
        id: 2,
        label: 'Profile',
        icon: 'pi pi-fw pi-user',
        to: '/profile'
    },
    {
        id: 3,
        label: 'Movies',
        icon: 'pi pi-fw pi-cog',
        to: '/movies'
    },
    {
        id: 4,
        label: 'Cinemas',
        icon: 'pi pi-fw pi-cog',
        to: '/cinemas'
    }
]);
</script>

<template>
    <Toolbar class="bg-transparent border-none align-items-start">
        <!-- <template #start>
          <img
              v-if="!hideLogo"
              :src="theme.logo"
              class="m-2"
              style="height: 2.3rem"
          >
        </template> -->

        <template #center>
            <div v-if="!hideTabs" class="flex">
                <router-link v-for="item in items" :key="item.label" class="py-2 px-4 m-2 text-color no-underline hover:text-900 focus:bg-primary border-round" :to="item.to">
                    <i :class="[item.icon, 'text-white']" />
                    <span class="p-button-label">{{ item.label }}</span>
                </router-link>
            </div>
        </template>

        <template #end>
            <div class="window-buttons">
                <Button v-for="(button, index) in buttons" :key="index" :class="`transparent border-noround ${button.class}`" @click="button.click">
                    <component :is="button.icon" class="text-color w-1rem h-full" />
                </Button>
            </div>
        </template>
    </Toolbar>
</template>

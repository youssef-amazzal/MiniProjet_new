<!-- eslint-disable prettier/prettier -->
<script setup>
import { ref } from 'vue';
import { useElementSize } from '@vueuse/core';

const editorCard = ref(null);
const { width, height } = useElementSize(editorCard);


const breadcrumbItems = ref([{ label: 'Rooms' }, { label: 'Room 1' }]);

const seatTypes = ref([
        { id: 1, name: 'Standard Class', color: 'orange' },
		{ id: 2, name: 'VIP Class', color: '#3a78c3' },
		{ id: 3, name: 'Student Class', color: 'blue' },
]);

const rowsCount = ref(10);
const columnsCount = ref(10);

const selectedType = ref(seatTypes.value[0]);

const setSelectedType = (type) => {
    selectedType.value = type;
    console.log(selectedType.value);
};

const addSeatChild = (e) => {
    const seat = document.createElement('div');
    seat.classList.add('w-3rem', 'h-3rem', 'bg-white', 'border-1');
    seat.style.backgroundColor = e.color;
    seat.style.borderRadius = '50%';
    seat.style.position = 'absolute';
    seat.style.top = e.pageY + 'px';
    seat.style.left = e.pageX + 'px';
    seat.style.transform = 'translate(-50%, -50%)';
    seat.style.zIndex = '1';
    seat.style.cursor = 'pointer';
    seat.addEventListener('click', () => {
        seat.remove();
    });
    e.target.appendChild(seat);
};


</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h5>Rooms</h5>
                <Breadcrumb :home="breadcrumbHome" :model="breadcrumbItems" />

                <div ref="editorCard" class="h-30rem overflow-hidden relative">
                    <div class="card flex flex-column justify-content-center align-items-center gap-4 absolute right-0 mt-8 mr-8 p-3 z-2">
                        <div v-for="type in seatTypes" :key="type.id" class="flex align-items-center" :ref="setTypesRefs">
                            <Button 
                                class="w-2rem h-2rem mr-2 border-round-lg z-5" 
                                :style="{ backgroundColor: type.color }"
                                @click="setSelectedType(type)"
                            />
                        </div>
                    </div>
                    <div class="editor overflow-auto flex flex-column align-items-center surface-800 p-5 relative" :style="{ height: height * 1 + 'px', width: width + 'px' }">
                        <div class="screen w-30rem h-20rem border-3 border-nl mb-6"></div>
                        <div v-for="row in rowsCount" :key="row" class="flex pointer">
                            <div v-for="column in columnsCount" :key="column" :id="row + '_' + column" class="w-3rem h-3rem bg-white border-1 border-400 border-round pointer" @click="addSeatChild(selectedType)"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style>
.editor {
    opacity: 0.8;
    background-image: radial-gradient(var(--surface-500) 0.9500000000000001px, var(--surface-50) 1.1px);
    background-size: 19px 19px;
}
</style>

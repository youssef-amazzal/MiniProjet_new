export default class ProjectionService {
    getprojections() {
        return fetch('demo/data/projections.json')
            .then((res) => res.json())
            .then((d) => d.data);
    }
}

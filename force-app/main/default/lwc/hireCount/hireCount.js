import { LightningElement, track } from 'lwc';
import getPlacements from '@salesforce/apex/HireCount.getPlacements';

export default class PlacementVisualizer extends LightningElement {
    @track filterType = 'last5years';
    @track selectedValue = '';
    @track placements = [];
    @track selectedValueOptions = [];

    filterOptions = [
        { label: 'Daily', value: 'daily' },
        { label: 'Weekly', value: 'weekly' },
        { label: 'Monthly', value: 'monthly' },
        { label: 'Yearly', value: 'yearly' },
        { label: 'Last 5 Years', value: 'last5years' }
    ];

    monthlyOptions = [
        { label: 'January', value: '1' },
        { label: 'February', value: '2' },
        { label: 'March', value: '3' },
        { label: 'April', value: '4' },
        { label: 'May', value: '5' },
        { label: 'June', value: '6' },
        { label: 'July', value: '7' },
        { label: 'August', value: '8' },
        { label: 'September', value: '9' },
        { label: 'October', value: '10' },
        { label: 'November', value: '11' },
        { label: 'December', value: '12' }
    ];

    yearlyOptions = Array.from({ length: 1001 }, (_, i) => {
        const year = 2000 + i;
        return { label: year.toString(), value: year.toString() };
    });

    columns = [
        { label: 'Selected Value', fieldName: 'selectedValue' },
        { label: 'Count of Placements', fieldName: 'count' }
    ];

    connectedCallback() {
        this.initializeDefaults();
        this.fetchPlacements();
    }

    initializeDefaults() {
        const today = new Date();
        const currentMonth = (today.getMonth() + 1).toString(); // Months are zero-indexed
        const currentYear = today.getFullYear().toString();

        if (this.filterType === 'monthly') {
            this.selectedValue = currentMonth;
            this.selectedValueOptions = this.monthlyOptions;
        } else if (this.filterType === 'yearly') {
            this.selectedValue = currentYear;
            this.selectedValueOptions = this.yearlyOptions;
        } else if (this.filterType === 'daily') {
            this.selectedValue = today.toISOString().split('T')[0]; // Format YYYY-MM-DD
        }

        // Reset options for filters that don't require `selectedValue`
        if (['weekly', 'last5years'].includes(this.filterType)) {
            this.selectedValue = '';
            this.selectedValueOptions = [];
        }
    }

    handleFilterChange(event) {
        this.filterType = event.detail.value;
        this.initializeDefaults();
        this.fetchPlacements();
    }

    handleValueChange(event) {
        this.selectedValue = event.detail.value;
        this.fetchPlacements();
    }

    fetchPlacements() {
        getPlacements({ filterType: this.filterType, selectedValue: this.selectedValue })
            .then(data => {
                this.placements = data;
            })
            .catch(error => {
                console.error('Error fetching placements:', error);
            });
    }
}
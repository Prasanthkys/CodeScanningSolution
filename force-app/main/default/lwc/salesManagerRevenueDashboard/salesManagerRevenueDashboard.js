import { LightningElement, wire, track } from 'lwc';
import getSalesManagerRevenue from '@salesforce/apex/SalesManagerRevenue.getSalesManagerRevenue';
import getJobInformationBySalesManager from '@salesforce/apex/SalesManagerRevenue.getJobInformationBySalesManager';

const columns = [
    { label: 'Sales Manager', fieldName: 'Submitted_By__c' },
    {
        label: 'Starts',
        fieldName: 'totalJobCount',
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'totalJobCount' },
            name: 'showDetails',
            variant: 'base'
        }
    },
    { label: 'Total Revenue', fieldName: 'totalRevenue' },
    { label: 'Future Revenue', fieldName: 'totalFutureRevenue' }
];

const modalColumns = [
    { label: 'Vendor Name', fieldName: 'Vendor_Name__c' },
    { label: 'Submitted By', fieldName: 'Submitted_By__c' },
    { label: 'Consultant Name', fieldName: 'Consultant_Name__c' },
    { label: 'Consultant Email', fieldName: 'Consultant_Email__c' },
    { label: 'Job Code', fieldName: 'Job_Code__c' },
    { label: 'Client Name', fieldName: 'Client_Name__c' },
    { label: 'Job Title', fieldName: 'Job_Title__c' },
    { label: 'Phone Number', fieldName: 'Phone_Number__c' },
    { label: 'Location', fieldName: 'Location__c' },
    { label: 'Job Status Changed On', fieldName: 'Status_Changed_On_Date__c' }
];

export default class SalesManagerRevenueDashboard extends LightningElement {

    @track isModalOpen = false;
    @track modalData = [];
    @track data = [];
    error;
    calendarFilter = 'monthly';
    selectedValue = this.getDefaultSelectedValue();
    customStartDate = null;
    customEndDate = null;
    columns = columns;
    modalColumns = modalColumns;
    @track isModalOpen1 = false;


    calendarOptions = [
        { label: 'Daily', value: 'daily' },
        { label: 'Weekly', value: 'weekly' },
        { label: 'Monthly', value: 'monthly' },
        { label: 'Yearly', value: 'yearly' },
        { label: 'Custom', value: 'custom' }
    ];

    monthOptions = [
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

    yearOptions = Array.from({ length: 1001 }, (_, i) => {
        const year = 2000 + i;
        return { label: year.toString(), value: year.toString() };
    });

    @wire(getSalesManagerRevenue, { filter: '$calendarFilter', selectedValue: '$selectedValue', customStartDate: '$customStartDate', customEndDate: '$customEndDate' })
    wiredCandidates({ error, data }) {
        if (data) {
            this.data = data.map(row => ({
                ...row,
                id: row.Client_Name__c // Assigning a unique key
            }));
            this.error = undefined;
            console.log('Candidates fetched successfully:', this.data);
        } else if (error) {
            this.error = error;
            this.data = [];
            console.error('Error fetching submitted candidates:', error);
        }
    }

    handleCalendarChange(event) {
        this.calendarFilter = event.detail.value;
        this.selectedValue = this.getDefaultSelectedValue();
    }

    handleValueChange(event) {
        this.selectedValue = event.detail.value;
    }

    handleCustomStartDateChange(event) {
        this.customStartDate = event.detail.value;
    }

    handleCustomEndDateChange(event) {
        this.customEndDate = event.detail.value;
    }

    getDefaultSelectedValue() {
        let today = new Date();
        if (this.calendarFilter === 'monthly') {
            return String(today.getMonth() + 1); // Default to current month
        } else {
            return String(today.getFullYear()); // Default to current year
        }
        return null;
       
    }

    get isMonthlyOrYearly() {
        return this.calendarFilter === 'monthly' || this.calendarFilter === 'yearly';
    }

    get options() {
        if (this.calendarFilter === 'monthly') {
            return this.monthOptions;
        } else if (this.calendarFilter === 'yearly') {
            return this.yearOptions;
        }
        return [];
    }

    get isCustom() {
        return this.calendarFilter === 'custom';
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'showDetails') {
            const salesManager = row.Submitted_By__c;
            this.fetchModalData(salesManager);
        }
    }

    fetchModalData(salesManager) {
        getJobInformationBySalesManager({ salesManager })
            .then(result => {
                this.modalData = result;
                this.isModalOpen = true;
                console.log('Modal data fetched successfully:', this.modalData);
            })
            .catch(error => {
                this.error = error;
                this.modalData = [];
                console.error('Error fetching modal data:', error);
            });
    }
    handleMaximize() {
        this.isModalOpen1 = true;
    }

    handleCloseModal() {
        this.isModalOpen1 = false;
    }

    closeModal1() {
        this.isModalOpen1 = false;
    }
    
    closeModal() {
        this.isModalOpen = false;
    }

    get tableHeightStyle() {
        // Calculate the height based on the number of rows in the table
        const rowHeight = 30; // Average height for each row
        const headerHeight = 50; // Height for the table header
        const maxTableHeight = 500; // Max height limit for the table

        const calculatedHeight = this.data.length * rowHeight + headerHeight;

        return `height: ${Math.min(calculatedHeight, maxTableHeight)}px;`;
    }
}
import { LightningElement, wire } from 'lwc';
import getDashboardData from '@salesforce/apex/EquipmentDashboardController.getDashboardData';

export default class EquipmentDashboard extends LightningElement {
    dashboardData;
    isLoading = true;
    error;
    searchTerm = '';

    @wire(getDashboardData)
    wiredDashboard({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.dashboardData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dashboardData = undefined;
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }

    get hasEquipment() {
        return this.dashboardData && this.dashboardData.equipmentList && this.dashboardData.equipmentList.length > 0;
    }

    get formattedTotalCost() {
        if (!this.dashboardData) return '$0';
        return this.formatCurrency(this.dashboardData.totalMaintenanceCost);
    }

    get filteredEquipment() {
        if (!this.dashboardData || !this.dashboardData.equipmentList) return [];

        return this.dashboardData.equipmentList
            .filter((eq) => {
                if (!this.searchTerm) return true;
                return (
                    (eq.name && eq.name.toLowerCase().includes(this.searchTerm)) ||
                    (eq.category && eq.category.toLowerCase().includes(this.searchTerm)) ||
                    (eq.status && eq.status.toLowerCase().includes(this.searchTerm))
                );
            })
            .map((eq) => ({
                ...eq,
                statusClass: this.getStatusClass(eq.status),
                formattedWarranty: eq.warrantyExpiry ? this.formatDate(eq.warrantyExpiry) : '—',
                formattedCost: this.formatCurrency(eq.totalMaintenanceCost)
            }));
    }

    getStatusClass(status) {
        const base = 'status-pill';
        switch (status) {
            case 'Under Repair':
                return `${base} status-repair`;
            case 'Operational':
                return `${base} status-operational`;
            case 'Retired':
                return `${base} status-retired`;
            default:
                return `${base} status-default`;
        }
    }

    formatCurrency(value) {
        const num = value || 0;
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            maximumFractionDigits: 0
        }).format(num);
    }

    formatDate(dateStr) {
        const d = new Date(dateStr);
        return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    }
}
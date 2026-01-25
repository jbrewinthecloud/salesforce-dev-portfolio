import { LightningElement } from 'lwc';
import getGreetingData from '@salesforce/apex/HelloStarterController.getGreetingData';

export default class HelloWorldStarter extends LightningElement {
    isLoading = true;
    hasError = false;
    errorMessage = '';
    firstName = '';
    todayTaskCount = 0;

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        this.isLoading = true;
        this.hasError = false;
        this.errorMessage = '';

        try {
            const result = await getGreetingData();
            // result: { firstName: string, todayTaskCount: number }
            this.firstName = result?.firstName || '';
            this.todayTaskCount = typeof result?.todayTaskCount === 'number' ? result.todayTaskCount : 0;
        } catch (e) {
            this.hasError = true;
            // Keep error user-friendly
            this.errorMessage = (e && (e.body && e.body.message)) ? e.body.message : 'Failed to load greeting data.';
        } finally {
            this.isLoading = false;
        }
    }

    get firstNameDisplay() {
        return this.firstName ? ` ${this.firstName}` : '';
    }
}

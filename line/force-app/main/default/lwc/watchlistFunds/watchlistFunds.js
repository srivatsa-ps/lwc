import { LightningElement, track, wire } from 'lwc';
import getWatchlistFunds from '@salesforce/apex/IEWatchlistMutualFundController.getWatchlistFunds';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class WatchlistFunds extends LightningElement {
    @track funds = [];
    @track error;

    @wire(getWatchlistFunds)
    wiredFunds({ error, data }) {
        if (data) {
            console.log(data);
            this.funds = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.funds = [];
        }
    }

    

    get isEmptyAndNoError() {
        return this.funds.length === 0 && !this.error;
    }
}

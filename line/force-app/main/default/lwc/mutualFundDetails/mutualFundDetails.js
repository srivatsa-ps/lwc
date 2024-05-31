import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getMutualFundDetails from '@salesforce/apex/IEMutualFundController.getMutualFundDetails';
import addToWatchlist from '@salesforce/apex/IEMutualFundController.addToWatchlist';
import buyMutualFund from '@salesforce/apex/IEMutualFundTransactionController.buyMutualFund';
import getInvestedAmount from '@salesforce/apex/IEMutualFundTransactionController.getInvestedAmount';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';

const FIELDS = [
    'IE_Mutual_Fund__c.Name',
    'IE_Mutual_Fund__c.Minimum_SIP__c',
    'IE_Mutual_Fund__c.Net_Asset_Value__c',
    'IE_Mutual_Fund__c.API_Scheme_Code__c'
];

export default class MutualFundDetails extends LightningElement {
    @api recordId;
    @track record;
    @track navData;
    @track error;
    @track buyAmount = 0;
    @track isInWatchlist = false;
    @track totalInvestedAmount = 0;
    chart;
    chartjsInitialized = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.record = data.fields;
            this.fetchNavData(this.record.API_Scheme_Code__c.value);
            this.fetchInvestedAmount();
        } else if (error) {
            this.error = error;
            this.showToast('Error loading record', error.body.message, 'error');
        }
    }

    fetchNavData(schemeCode) {
        getMutualFundDetails({ schemeCode })
            .then(data => {
                this.navData = data.navData;
                this.initializeChart();
            })
            .catch(error => {
                this.error = error;
                this.showToast('Error loading NAV data', error.body.message, 'error');
            });
    }

    fetchInvestedAmount() {
        getInvestedAmount({ mutualFundId: this.recordId })
            .then(data => {
                console.log('Total Invested Amount: ', data); // Debugging line
                this.totalInvestedAmount = data;
            })
            .catch(error => {
                this.error = error;
                this.showToast('Error loading invested amount', error.body.message, 'error');
            });
    }

    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        loadScript(this, chartjs)
            .then(() => {
                if (this.navData) {
                    this.initializeChart();
                }
            })
            .catch(error => {
                this.showToast('Error loading Chart.js', error.message, 'error');
            });
    }

    initializeChart() {
        if (!this.navData || !this.chartjsInitialized) {
            return;
        }

        const canvasElement = this.template.querySelector('canvas.linechart');
        if (!canvasElement) {
            console.error('Canvas element not found');
            return;
        }

        const ctx = canvasElement.getContext('2d');
        const dates = this.navData.map(item => item.navDate);
        const navValues = this.navData.map(item => item.navValue);

        this.chart = new window.Chart(ctx, {
            type: 'line',
            data: {
                labels: dates,
                datasets: [
                    {
                        label: 'NAV Data',
                        data: navValues,
                        fill: false,
                        borderColor: 'rgb(75, 192, 192)',
                        tension: 0.1
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    x: {
                        display: true,
                        title: {
                            display: true,
                            text: 'Date'
                        }
                    },
                    y: {
                        display: true,
                        title: {
                            display: true,
                            text: 'NAV'
                        }
                    }
                }
            }
        });
    }

    handleAmountChange(event) {
        this.buyAmount = event.target.value;
    }

    handleBuy() {
        const minSip = this.record.Minimum_SIP__c.value;
        console.log('Buy Amount: ', this.buyAmount); // Debugging line
        console.log('Minimum SIP: ', minSip); // Debugging line

        if (this.buyAmount % minSip === 0) {
            buyMutualFund({ mutualFundId: this.recordId, investedAmount: this.buyAmount })
                .then(() => {
                    console.log('Purchase successful'); // Debugging line
                    this.showToast('Success', `You have bought mutual fund units worth ${this.buyAmount}`, 'success');
                    this.fetchInvestedAmount();
                })
                .catch(error => {
                    console.error('Purchase error: ', error); // Debugging line
                    this.showToast('Error', error.body.message, 'error');
                });
        } else {
            console.log('Invalid amount, not a multiple of minimum SIP'); // Debugging line
            this.showToast('Error', `The amount should be a multiple of the minimum SIP: ${minSip}`, 'error');
        }
    }

    handleSell() {
        this.showToast('Success', 'Sell functionality is not implemented yet', 'success');
    }

    handleAddToWatchlist() {
        addToWatchlist({ mutualFundId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Added to watchlist', 'success');
                this.isInWatchlist = true;
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    get watchlistButtonConfig() {
        return this.isInWatchlist 
            ? { label: 'Added to Watchlist', variant: 'success' } 
            : { label: 'Add to Watchlist', variant: 'neutral' };
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}

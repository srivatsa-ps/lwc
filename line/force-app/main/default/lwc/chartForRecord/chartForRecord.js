import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getNavData from '@salesforce/apex/NavDataControllerRecord.getNavData';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import the field
const FIELDS = ['IE_Mutual_Fund__c.API_Scheme_Code__c'];

export default class LineChart extends LightningElement {
    @api recordId;
    @track navData;
    @track error;
    chart;
    chartjsInitialized = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    mutualFundRecord;

    @wire(getNavData, { schemeCode: '$schemeCode' })
    wiredNavData({ error, data }) {
        if (data) {
            this.navData = data;
            this.initializeChart();
        } else if (error) {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading NAV data',
                    message: error.body.message,
                    variant: 'error',
                })
            );
        }
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
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chart.js',
                        message: error.message,
                        variant: 'error',
                    })
                );
            });
    }

    get schemeCode() {
        return this.mutualFundRecord?.data?.fields?.API_Scheme_Code__c?.value;
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
}

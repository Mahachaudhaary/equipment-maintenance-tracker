import { LightningElement, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import createServiceRequest
from '@salesforce/apex/ServiceRequestController.createServiceRequest';

export default class ServiceRequestQuickForm extends LightningElement {

    @api recordId;

    description = '';

    priority = 'Medium';

    status = 'New';

    priorityOptions = [
        { label: 'Low', value: 'Low' },
        { label: 'Medium', value: 'Medium' },
        { label: 'High', value: 'High' },
        { label: 'Critical', value: 'Critical' }
    ];

    statusOptions = [
        { label: 'New', value: 'New' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'On Hold', value: 'On Hold' },
        { label: 'Resolved', value: 'Resolved' },
        { label: 'Closed', value: 'Closed' }
    ];

    handleDescription(event) {

        this.description = event.target.value;

    }

    handlePriority(event) {

        this.priority = event.target.value;

    }

    handleStatus(event) {

        this.status = event.target.value;

    }

    createRequest() {

        // Client-side validation before calling Apex
        if (!this.description || this.description.trim() === '') {

            this.dispatchEvent(

                new ShowToastEvent({

                    title: 'Missing Information',

                    message: 'Issue Description is required.',

                    variant: 'error'

                })

            );

            return;

        }

        createServiceRequest({

            equipmentId: this.recordId,
            description: this.description,
            priority: this.priority,
            status: this.status

        })

        .then(() => {

            this.dispatchEvent(

                new ShowToastEvent({

                    title: 'Success',

                    message: 'Service Request Created Successfully',

                    variant: 'success'

                })

            );

            this.description = '';

            this.priority = 'Medium';

            this.status = 'New';

        })

        .catch(error => {

            this.dispatchEvent(

                new ShowToastEvent({

                    title: 'Error',

                    message: error.body.message,

                    variant: 'error'

                })

            );

        });

    }

}
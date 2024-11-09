import { api, wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import createContentLink from '@salesforce/apex/AttachmentsController.createContentLink';

import CONTENT_VERSION_OBJECT from "@salesforce/schema/ContentVersion";
import TITLE_FIELD from "@salesforce/schema/ContentVersion.Title";
import DESCRIPTION_FIELD from "@salesforce/schema/ContentVersion.Description";
import TYPE_FIELD from "@salesforce/schema/ContentVersion.Type__c";
import PATH_ON_CLIENT_FIELD from "@salesforce/schema/ContentVersion.PathOnClient";
import VERSION_DATA_FIELD from "@salesforce/schema/ContentVersion.VersionData";

import { MessageContext, publish } from 'lightning/messageService';
import COMPONENT_REFRESH_CHANNEL from "@salesforce/messageChannel/componentRefresh__c";

export default class UploadFileModal extends LightningModal {
    @api recordId;
    objectApiName = CONTENT_VERSION_OBJECT;
    fields = [TITLE_FIELD, TYPE_FIELD, DESCRIPTION_FIELD];
    @track fileData = {};

    @wire(MessageContext)
    messageContext;

    handleClose() {
        this.close();
    }

    async handleSave() {
        try {
            const isValid = [...this.template.querySelectorAll("lightning-input-field"),
            ...this.template.querySelectorAll('lightning-input')]?.filter((field) => !field.reportValidity())
                ?.length === 0;

            if (isValid) {
                const contentVersion = await createRecord({ apiName: CONTENT_VERSION_OBJECT.objectApiName, fields: this.fileData });
                await createContentLink({ contentVersionId: contentVersion.id, recordId: this.recordId });
            }
            publish(this.messageContext, COMPONENT_REFRESH_CHANNEL, { recordId: this.recordId });
            this.showSuccessToast();
            this.close();
        } catch (error) {
            this.showErrorToast(error.message)
        }

    }

    handleUploadChange(event) {
        const file = event.target.files[0]
        const reader = new FileReader()
        reader.onload = () => {
            const base64 = reader.result.split(',')[1]
            this.fileData[PATH_ON_CLIENT_FIELD.fieldApiName] = file.name;
            this.fileData[VERSION_DATA_FIELD.fieldApiName] = base64;
            this.showSuccessToast('File successfully uploaded!')
        }
        reader.readAsDataURL(file)
    }

    handleInputChange(event) {
        this.fileData[event.currentTarget.fieldName] = event.detail.value;
    }

    handleSubmit(event) {
        event.preventDefault();
    }

    showSuccessToast(title) {
        const event = new ShowToastEvent({
            title: title || 'Record created!',
            message: 'Record successfully created!',
            variant: 'success',
        });
        this.dispatchEvent(event);
    }

    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: message || 'Error while creating a record!',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    get isUploadDisabled() {
        return !this.fileData?.[TYPE_FIELD.fieldApiName]?.length;
    }

    get uploadedFileName() {
        return this.fileData[PATH_ON_CLIENT_FIELD.fieldApiName];
    }
}
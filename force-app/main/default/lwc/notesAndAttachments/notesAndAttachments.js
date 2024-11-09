import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAttachments from '@salesforce/apex/AttachmentsController.getRelatedAttachments';
import uploadFileModal from "c/uploadFileModal";
import { getSObjectValue } from '@salesforce/apex';
import { refreshApex } from '@salesforce/apex';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import COMPONENT_REFRESH_CHANNEL from "@salesforce/messageChannel/componentRefresh__c";

import ID_FIELD from "@salesforce/schema/ContentVersion.Id";
import TITLE_FIELD from "@salesforce/schema/ContentVersion.Title";
import TYPE_FIELD from "@salesforce/schema/ContentVersion.Type__c";
import FILE_EXTENSION_FIELD from "@salesforce/schema/ContentVersion.FileExtension";
import SIZE_FIELD from "@salesforce/schema/ContentVersion.ContentSize";
import CONTENT_DOCUMENT_ID_FIELD from "@salesforce/schema/ContentVersion.ContentDocumentId";

const ACTIONS = [
    { label: 'View File', name: 'view_file' }
];

const COLUMNS = [
    {
        label: 'Title',
        fieldName: TITLE_FIELD.fieldApiName,
        wrapText: true,
    },
    {
        label: 'Type',
        fieldName: TYPE_FIELD.fieldApiName,
    },
    {
        label: 'File extension',
        fieldName: FILE_EXTENSION_FIELD.fieldApiName,
    },
    { label: 'File Size', fieldName: SIZE_FIELD.fieldApiName, },
    { type: 'action', typeAttributes: { rowActions: ACTIONS, menuAlignment: 'right' } }
];

const MAX_ATTACHMENTS_SIZE = 3;

export default class NotesAndAttachments extends NavigationMixin(LightningElement) {
    @api recordId;
    // compact
    // full
    @api variant = 'compact';
    columns = COLUMNS;
    viewAllPageUrl;
    subscription;
    wiredAttachments;
    _attachments;

    @wire(MessageContext)
    messageContext;

    @wire(getAttachments, { recordId: '$recordId' })
    getAttachments(result) {
        this.wiredAttachments = result
        if (result.error) {
            console.error(result.error);
        } else if (result.data) {
            console.log(result.data);
            this.attachments = result.data;
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                COMPONENT_REFRESH_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        if (this.recordId === message.recordId) {
            refreshApex(this.wiredAttachments);
        }
    }

    handleViewAllClick() {
        const compDefinition = {
            componentDef: 'c:notesAndAttachments',
            attributes: {
                recordId: this.recordId,
                variant: 'full'
            },
        };
        const encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef,
            },
        });
    }

    handleRowAction(event) {
        const contentDocumentId = event.detail.row?.[CONTENT_DOCUMENT_ID_FIELD?.fieldApiName];
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: contentDocumentId
            }
        });
    }

    formatBytes(bytes, decimals) {
        if (bytes == 0) return '0 Bytes';
        const k = 1024,
            dm = decimals ?? 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    handleUploadFiles() {
        uploadFileModal.open({ recordId: this.recordId })
    }

    parseAttachments(attachments) {
        if (!this.isFull) {
            attachments = attachments?.slice(0, MAX_ATTACHMENTS_SIZE);
        }
        return attachments?.map(attachment => ({
            ...attachment,
            [SIZE_FIELD.fieldApiName]: this.formatBytes(getSObjectValue(attachment, SIZE_FIELD), 1)
        }));
    }

    get attachments() {
        return this.parseAttachments(this._attachments);
    }

    set attachments(value) {
        this._attachments = value;
    }

    get showAttachments() {
        return this._attachments?.length;
    }

    get cardTitle() {
        const realCount = this._attachments?.length || 0;
        const slicedCount = this.attachments?.length || 0;
        const countText = realCount > slicedCount ? `${MAX_ATTACHMENTS_SIZE}+` : `${slicedCount}`
        return `Notes & Attachments (${countText})`
    }

    get keyField() {
        return ID_FIELD?.fieldApiName;
    }

    get isFull() {
        return this.variant === 'full';
    }

    get showFooter() {
        return this.showAttachments && !this.isFull;
    }
}
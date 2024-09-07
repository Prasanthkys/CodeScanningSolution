import { LightningElement, wire, track } from 'lwc';
import getRepositories from '@salesforce/apex/GitHubController.getRepositories';
import getBranches from '@salesforce/apex/GitHubController.getBranches';

export default class GithubRepositories extends LightningElement {
    @track repoOptions = [];
    @track branchOptions = [];
    @track selectedRepo;
    @track selectedBranch;
    @track branchesVisible = false;

    @wire(getRepositories)
    wiredRepos({ error, data }) {
        if (data) {
            this.repoOptions = data.map(repo => ({ label: repo, value: repo }));
        } else if (error) {
            console.error('Error fetching repositories:', error);
        }
    }

    handleRepoChange(event) {
        this.selectedRepo = event.detail.value;
        this.branchesVisible = true;
        getBranches({ repositoryName: this.selectedRepo })
            .then(result => {
                this.branchOptions = result.map(branch => ({ label: branch, value: branch }));
            })
            .catch(error => {
                console.error('Error fetching branches:', error);
            });
    }

    handleBranchChange(event) {
        this.selectedBranch = event.detail.value;
        // Do something with the selected branch
    }
}

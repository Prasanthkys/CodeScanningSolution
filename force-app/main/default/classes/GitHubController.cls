public with sharing class GitHubController {
    private static final String GITHUB_API_BASE_URL = 'https://api.github.com/';
    private static final String ACCESS_TOKEN = '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';//Access Token

    @AuraEnabled(cacheable=true)
    public static List<String> getRepositories() {
        String endpoint = GITHUB_API_BASE_URL + 'user/repos';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        req.setHeader('Accept', 'application/vnd.github.v3+json');
        System.debug('TOKEN');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        List<String> repoNames = new List<String>();
        if (res.getStatusCode() == 200) {
            List<Object> repos = (List<Object>) JSON.deserializeUntyped(res.getBody());
            for (Object repo : repos) {
                Map<String, Object> repoMap = (Map<String, Object>) repo;
                repoNames.add((String) repoMap.get('name'));
            }
        }
        return repoNames;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBranches(String repositoryName) {
        String endpoint = GITHUB_API_BASE_URL + 'repos/Prasanthkys/' + repositoryName + '/branches'; // Replace YOUR_GITHUB_USERNAME with your GitHub username
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        req.setHeader('Accept', 'application/vnd.github.v3+json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        List<String> branchNames = new List<String>();
        if (res.getStatusCode() == 200) {
            List<Object> branches = (List<Object>) JSON.deserializeUntyped(res.getBody());
            for (Object branch : branches) {
                Map<String, Object> branchMap = (Map<String, Object>) branch;
                branchNames.add((String) branchMap.get('name'));
            }
        }
        return branchNames;
    }
}

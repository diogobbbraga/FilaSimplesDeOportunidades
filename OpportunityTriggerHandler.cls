/*
* @author Diogo Braga
* @date 19/06/2023
*/
public class OpportunityTriggerHandler extends TriggerHandler {
    
    protected override void beforeInsert() {
        List<Opportunity> listNew = (List<Opportunity>) this.getTriggerNew();
        OpportunityTeamBO opportunityTeamBO = new OpportunityTeamBO();
        opportunityTeamBO.init();
        opportunityTeamBO.setOwnerForNewOpportunities(listNew);
    }
    
    protected override void afterUpdate() {
        List<Opportunity> listNew = (List<Opportunity>) this.getTriggerNew();
        Map<Id, Opportunity> mapOld = (Map<Id, Opportunity>) this.getTriggerMapOld();
        
        List<Id> listOwnersIdOfOpportunitiesClosing = new List<Id>();
        for(Opportunity opportunityNew : listNew) {
            if(opportunityNew.isClosed && !mapOld.get(opportunityNew.Id).isClosed) {
                listOwnersIdOfOpportunitiesClosing.add(opportunityNew.OwnerId);
            }
        }
        
        if(listOwnersIdOfOpportunitiesClosing.size() != 0) {
            OpportunityTeamBO opportunityTeamBO = new OpportunityTeamBO();
            opportunityTeamBO.init();
            opportunityTeamBO.setOldsOpportunitiesToAvailableOwners(listOwnersIdOfOpportunitiesClosing.size());
        }
    }
}

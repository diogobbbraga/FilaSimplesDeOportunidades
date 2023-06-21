/*
* @author Diogo Braga
* @date 19/06/2023
*/
trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new OpportunityTriggerHandler().run();
}

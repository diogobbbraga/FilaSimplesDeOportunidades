/*
* @author Diogo Braga
* @date 19/06/2023
*/
public class OpportunityTeamDAO {

    public static List<User> getUsersByDivision(List<String> listDivisions) {
        return [SELECT Id,
                Division
                FROM User
                WHERE Division IN :listDivisions];
    }
    
    public static Map<String, Integer> getMapTotalOpportunitiesByUser(Set<Id> setUserIds) {
        Map<String, Integer> mapTotalOpportunitiesByUser = new Map<String, Integer>();
        
        List<AggregateResult> listAggregateOpportunities = [SELECT COUNT(Id),
                                                            OwnerId
                                                            FROM Opportunity
                                                            WHERE OwnerId IN :setUserIds
                                                            AND IsClosed = FALSE
                                                            GROUP BY OwnerId];
        System.debug(json.serializePretty(listAggregateOpportunities));
        for (AggregateResult aggregateOpportunity : listAggregateOpportunities)  {
            mapTotalOpportunitiesByUser.put(String.valueOf(aggregateOpportunity.get('OwnerId')), Integer.valueOf(aggregateOpportunity.get('expr0')));
        } 
		return mapTotalOpportunitiesByUser;
    }
    
    public static List<Opportunity> getOldOpportunities(Integer limitOpportunitiesByUser, Set<Id> setUserIds) {
        Integer limitQuery = limitOpportunitiesByUser * setUserIds.size();
        return [SELECT Id,
                OwnerId,
                Amount
                FROM Opportunity
                WHERE OwnerId NOT IN :setUserIds
                AND IsClosed = FALSE
                ORDER BY CreatedDate ASC
                LIMIT :limitQuery];
    }
}

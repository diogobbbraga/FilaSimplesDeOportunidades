/*
* @author Diogo Braga
* @date 19/06/2023
*/
public class OpportunityTeamBO {
    private final String TEAM_A = 'Time A';
    private final String TEAM_B = 'Time B';
    private final Decimal LIMIT_TEAM_A = 10000;
    private final Integer LIMIT_TEAM_MEMBER_OPPORTUNITIES = 2;
    
    private Map<String,List<TeamMember>> teams;
    private Set<Id> setUserIds = new Set<Id>();
    
    public void init() {
        List<String> listDivisions = new List<String>{TEAM_A,TEAM_B};
        List<User> listUsers = OpportunityTeamDAO.getUsersByDivision(listDivisions);
        List<Id> listUserIds = new List<Id>();
            
        this.teams = new Map<String,List<TeamMember>>();
        
        for(User user : listUsers) {
            this.setUserIds.add(user.Id);
            
            if(this.teams.containsKey(user.Division)) {
                List<TeamMember> listTeamMembers = this.teams.get(user.Division);
                listTeamMembers.add(new TeamMember(user.Id));
            } else {
                List<TeamMember> listTeamMembers = new List<TeamMember>{new TeamMember(user.Id)};
                this.teams.put(user.Division, listTeamMembers);
            }
        }
        
        Map<String, Integer> mapTotalOpportunitiesByUser = OpportunityTeamDAO.getMapTotalOpportunitiesByUser(this.setUserIds);
        
        for(List<TeamMember> listTeamMembers : this.teams.values()) {
            for(TeamMember teamMember : listTeamMembers) {
                if(mapTotalOpportunitiesByUser.containsKey(teamMember.userId)) {
                    teamMember.totalActiveOpportunities = mapTotalOpportunitiesByUser.get(teamMember.userId);
                } else {
                    teamMember.totalActiveOpportunities = 0;
                }
            }
        }
    }
    
    public void setOwnerForNewOpportunities(List<Opportunity> listNew) {
        for(Opportunity opportunity : listNew) {
            if(setUserIds.contains(opportunity.OwnerId)) {
                continue;
            }
            if(isTeamA(opportunity)) {
                opportunity.OwnerId = getTeamMemberToOpportunity(TEAM_A, opportunity);
            } else {
                opportunity.OwnerId = getTeamMemberToOpportunity(TEAM_B, opportunity);
            }
        }
    }
    
    public void setOldsOpportunitiesToAvailableOwners(Integer countOpportunitiesClosing) {
        List<Opportunity> listOldOpportunities = OpportunityTeamDAO.getOldOpportunities(LIMIT_TEAM_MEMBER_OPPORTUNITIES, setUserIds);
        if(listOldOpportunities == null) {
            return;
        }
        List<Opportunity> listOpportunitiesToUpdate = new List<Opportunity>();
        
        for(Opportunity oldOpportunity : listOldOpportunities) {
            Id tempOldOpportunityOwnerId = oldOpportunity.OwnerId;
            if(isTeamA(oldOpportunity)) {
                oldOpportunity.OwnerId = getTeamMemberToOpportunity(TEAM_A, oldOpportunity);
            } else {
                oldOpportunity.OwnerId = getTeamMemberToOpportunity(TEAM_B, oldOpportunity);
            }
            if(oldOpportunity.OwnerId != tempOldOpportunityOwnerId) {
                listOpportunitiesToUpdate.add(oldOpportunity);
            }
        }
        
        update listOpportunitiesToUpdate;
    }
    
    private Boolean isTeamA(Opportunity opportunity) {
        return opportunity.Amount < LIMIT_TEAM_A;
    } 
    
    private Id getTeamMemberToOpportunity(String team, Opportunity opportunity) {
        TeamMember teamMemberSelected;
        for(TeamMember teamMember : this.teams.get(team)) {
            if(teamMember.totalActiveOpportunities < LIMIT_TEAM_MEMBER_OPPORTUNITIES) {
                if(teamMemberSelected == null || teamMemberSelected.totalActiveOpportunities > teamMember.totalActiveOpportunities) {
                    teamMemberSelected = teamMember;
                }
            }
        }
        if(teamMemberSelected == null) {
			return opportunity.OwnerId;            
        } else {
            teamMemberSelected.totalActiveOpportunities++;
            return teamMemberSelected.userId;
        }
    }
    
    private class TeamMember {
        public TeamMember(String userId) {
            this.userId = userId;
        }
        public Id userId {get; set;}
        public Integer totalActiveOpportunities {get; set;}
    }
}

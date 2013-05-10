ALTER PROCEDURE Age_Betlist_SelIDRunningAll_API
	@custid int = NULL,	
	@username varchar(50) = NULL,
	@Language varchar(2) = 'E'
AS
--Vinh@20080116: running betlist for bet feed
if @custid is null
	select @custid = custid from customer with (nolock) where username = @username

select
	s.sporttype,
	a.teamid as awayid,
	case 
		when b.bettype IN(1,7,17,20) then case b.betteam when 'h' then 'Home' else 'Away' end --hdp & money line
		when b.bettype IN(2,12)   then case b.betteam when 'h' then 'Odd'  else 'Even' end --odd/even
		when b.bettype IN(3,8,18) then case b.betteam when 'h' then 'Over'  else 'Under' end --over/under
		when b.bettype IN(5,15) then b.betteam --1x2
		when b.bettype IN(6) then b.betteam --total goal
	end as choice,
	b.transdate,
	l.leagueid,		
	b.matchid,	
	h.teamid as homeid,	
	c.username,	
	b.bettype,	
	convert(float, b.hdp1) as hdp1, convert(float, b.hdp2) as hdp2, 
	b.stake,
	b.transid,
	case b.liveindicator when 1 then b.livehomescore else -1 end as livehomescore,
	case b.liveindicator when 1 then b.liveawayscore else -1 end as liveawayscore,
	b.odds,
	case when CHARINDEX('hk', c.ugroup) > 0 then 'HK' else case when b.currency = 15 then 'Indo' else 'Malay' end end as OddsType
from 
	dbo.bettrans AS b with (nolock)
	INNER JOIN dbo.customer AS c with (nolock) ON b.custid=c.custid 
	INNER JOIN dbo.match AS m with (nolock) ON b.matchid=m.matchid 
	INNER JOIN dbo.team AS h with (nolock) ON h.teamid=m.homeid 
	INNER JOIN dbo.team AS a with (nolock) ON a.teamid=m.awayid 
	INNER JOIN dbo.league AS l with (nolock) ON l.leagueid=m.leagueid 
	INNER JOIN dbo.bettype with (nolock) ON bettype.typeid=b.bettype
	inner join Sports as s with (nolock) on l.sporttype = s.sporttype
where	
	b.recommend=@custid and
	b.status = 'running'  and
	b.bettype < 99
union all
select
	s.sporttype,
	'' as awayid,
	h.teamname as choice,	
	b.transdate,	
	l.leagueid,	
	b.matchid,
	h.teamid as homeid,		
	c.username,	
	b.bettype,	
	b.hdp1,b.hdp2,
	b.stake,
	b.transid,
	case b.liveindicator when 1 then b.livehomescore else -1 end as livehomescore,
	case b.liveindicator when 1 then b.liveawayscore else -1 end as liveawayscore,
	b.odds,
	'' as OddsType
from 
	dbo.bettrans AS b with (nolock)
	INNER JOIN dbo.customer AS c with (nolock) ON b.custid=c.custid 
	INNER JOIN dbo.outright AS m with (nolock) ON b.matchid=m.orid
	INNER JOIN dbo.team AS h with (nolock) ON h.teamid=m.teamid
	INNER JOIN dbo.league AS l with (nolock) ON l.leagueid=m.leagueid 
	INNER JOIN dbo.bettype with (nolock) ON bettype.typeid=b.bettype
	inner join Sports as s with (nolock) on l.sporttype = s.sporttype 
where
	b.recommend=@custid and
	b.status = 'running' and
	b.bettype = 10
UNION ALL
select
	'',
	'' away,	
	'' as choice,	
	b.transdate,	
	''  leagueid,	
	b.matchid,
	'' homeid,
	c.username,	
	b.bettype,			
	b.hdp1,b.hdp2,
	b.stake,
	b.transid,
	case b.liveindicator when 1 then b.livehomescore else -1 end as livehomescore,
	case b.liveindicator when 1 then b.liveawayscore else -1 end as liveawayscore,
	b.odds,
	'' as OddsType
from 
	dbo.bettrans b (nolock) 
	INNER JOIN dbo.customer c (nolock) ON b.custid=c.custid
where
	b.recommend=@custid and		
	b.status=('running')  and
	b.bettype = 9

GO
GRANT EXECUTE ON dbo.Age_Betlist_SelIDRunningAll_API TO [bodbDownlineNet]
GO
GRANT EXECUTE ON dbo.Age_Betlist_SelIDRunningAll_API TO [bodbDownlineNetView]

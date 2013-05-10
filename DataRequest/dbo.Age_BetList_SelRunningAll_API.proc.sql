ALTER PROCEDURE [dbo].[Age_BetList_SelRunningAll_API]
	@custid int = NULL,	
	@username varchar(50) = NULL,
	@Language varchar(2) = 'E'
AS

if @custid is null
	select @custid = custid from customer with (nolock) where username = @username

select
	convert(float, b.hdp1) as hdp1, convert(float, b.hdp2) as hdp2, 
	b.odds,b.stake,
	b.betteam,
	b.status,
	convert(nvarchar(20),b.transid) AS refno,
	b.transdate,
	b.transid,
	b.bettype,
	b.matchid,
	case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
	case @Language when 'E' then h.teamname when 'J' then isnull(h.teamnamej, h.teamname) else isnull(h.teamnamec_uni, h.teamname) end as home,
	case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as away,
	case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end as leaguename,
	c.username,
	b.comstatus,
	(winlost-actual_stake)  winlost,
	(playercomm) AS playercomm,
	b.mpositiontaking,
	b.apositiontaking,
	b.liveindicator,
	b.livehomescore,
	b.liveawayscore,
	b.spositiontaking,
	case when CHARINDEX('hk', c.ugroup) > 0 then 'HK' else case when b.currency = 15 then 'Indo' else 'Malay' end end as OddsType,
	s.sportname
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
	b.hdp1,b.hdp2,
	b.odds,b.stake,
	b.betteam,
	b.status,
	convert(nvarchar(20),b.transid) AS refno,
	b.transdate,
	b.transid,
	b.bettype,
	b.matchid,
	case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
	case @Language when 'E' then h.teamname when 'J' then isnull(h.teamnamej, h.teamname) else isnull(h.teamnamec_uni, h.teamname) end as home,
	'' as away,
	case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end as leaguename,
	c.username,
	b.comstatus,
	(winlost-case when b.odds>0 then stake else stake*abs(b.odds) end)  winlost,
	(playercomm) AS playercomm,
	b.mpositiontaking,
	b.apositiontaking,
	b.liveindicator,
	b.livehomescore,
	b.liveawayscore,
	b.spositiontaking,
	'' as OddsType,
	s.sportname
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
	b.hdp1,b.hdp2,
	b.odds,b.stake,
	b.betteam,
	b.status,
	convert(nvarchar(20),b.transid) AS refno,
	b.transdate,
	b.transid,
	9 bettype,
	b.matchid,
	'Mix Parlay' typenamee,
	'' home,
	'' away,
	''  leaguename,
	c.username,
	b.comstatus,
	(winlost-actual_stake)  winlost,
	(playercomm) playercomm,
	b.mpositiontaking,
	b.apositiontaking,
	b.liveindicator,
	b.livehomescore,
	b.liveawayscore,
	b.spositiontaking,
	'' as OddsType,
	''
from 
	dbo.bettrans b (nolock) 
	INNER JOIN dbo.customer c (nolock) ON b.custid=c.custid
where
	b.recommend=@custid and		
	b.status=('running')  and
	b.bettype = 9

GO
GRANT EXECUTE ON dbo.Age_BetList_SelRunningAll_API TO [bodbDownlineNet]
GO
GRANT EXECUTE ON dbo.Age_BetList_SelRunningAll_API TO [bodbDownlineNetView]

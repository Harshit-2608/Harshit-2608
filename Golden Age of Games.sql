--In this Project we will explore the best selling Video Games data to provide insights in the data
select *
from dbo.Game_Sales_Data
where year = 1982;


-- 1. The ten best-selling video games

Select top 10 *
from [dbo].[Game_Sales_Data]
order by Total_Shipped desc;
--the best-selling video games were released between 1985 to 2017




-- 2. finding Missing review scores games count
select count(Name)
from dbo.Game_Sales_Data
where Critic_Score is NULL
	and User_Score is null;




-- 3. Years that video game critics loved
select top 10 Year
		,round(avg(Critic_Score),2) as Avg_critic_score
from dbo.Game_Sales_Data
group by Year
order by Avg_critic_score desc;




-- 4. Was 1982 really that great?
select *
from dbo.Game_Sales_Data
where year = 1982;
-- No it is not, but we dont have much critic scores in this year. so we will have to update our SQL query to reflect this

select top 10 Year
		,round(avg(Critic_Score),2) as Avg_critic_score
		,count(Critic_Score) as Cnt_Critic_score
from dbo.Game_Sales_Data
group by Year
having count(Critic_Score) > 4
order by Avg_critic_score desc;


-- 5. Years that dropped off the critics' favorites list
select top 10 Year
		,round(avg(Critic_Score),2) as Avg_critic_score
		,count(Critic_Score) as Cnt_Critic_score
from dbo.Game_Sales_Data
group by Year
having count(Critic_Score) <= 4
order by Avg_critic_score desc;
-- this shows the list of years which are dropped off from favorites list because they don't have enough data



--6. Years video game players loved
select top 10 Year
		,round(avg(User_Score),2) as Avg_user_score
		,count(User_Score) as Cnt_user_score
from dbo.Game_Sales_Data
group by Year
having count(User_Score) > 4
order by Avg_user_score desc;

-- similar to critic score we can find the top years by user score.






--7. Years that both players and critics loved

with critic_loved as (
select top 15 Year
		,round(avg(Critic_Score),2) as Avg_critic_score
		,count(Critic_Score) as Cnt_Critic_score
from dbo.Game_Sales_Data
group by Year
having count(Critic_Score) > 4
order by Avg_critic_score desc
)
, player_loved as (
select top 15 Year
		,round(avg(User_Score),2) as Avg_user_score
		,count(User_Score) as Cnt_user_score
from dbo.Game_Sales_Data
group by Year
having count(User_Score) > 4
order by Avg_user_score desc
)
select year 
	from critic_loved
intersect
select year
	from player_loved;

-- 2012,2013, 2014, 2020 are the best video game years based on the users and critic scores (years with having enough scores data to compare)






--8. Sales in the best video game years

with critic_loved as (
select top 15 Year
		,round(avg(Critic_Score),2) as Avg_critic_score
		,count(Critic_Score) as Cnt_Critic_score
from dbo.Game_Sales_Data
group by Year
having count(Critic_Score) > 4
order by Avg_critic_score desc
)
, player_loved as (
select top 15 Year
		,round(avg(User_Score),2) as Avg_user_score
		,count(User_Score) as Cnt_user_score
from dbo.Game_Sales_Data
group by Year
having count(User_Score) > 4
order by Avg_user_score desc
)
select year,
		round(sum(Total_Shipped),2) as Total_games_sold
from dbo.Game_Sales_Data
where year in (select year 
					from critic_loved
				intersect
				select year
					from player_loved)
group by year
order by Total_games_sold desc;

-- this concludes our analysis, we were able to find the top video game years where both Critics and users scores are highest and we found the total game copies sold in those years





if ( .Platform$OS.type == 'windows' ) memory.limit( 256000 )

options("lodown.cachaca.savecache"=FALSE)

library(lodown)
lodown( "hmda" , output_dir = file.path( getwd() ) )
library(DBI)
dbdir <- file.path( getwd() , "SQLite.db" )
db <- dbConnect( RSQLite::SQLite() , dbdir )

dbSendQuery( db , "ALTER TABLE hmda_2015 ADD COLUMN multifamily_home INTEGER" )

dbSendQuery( db , 
	"UPDATE hmda_2015 
	SET multifamily_home = 
		CASE WHEN ( propertytype = 3 ) THEN 1 ELSE 0 END" 
)
dbGetQuery( db , "SELECT COUNT(*) FROM hmda_2015" )

dbGetQuery( db ,
	"SELECT
		loanpurpose ,
		COUNT(*) 
	FROM hmda_2015
	GROUP BY loanpurpose"
)
dbGetQuery( db , "SELECT AVG( loanamount ) FROM hmda_2015" )

dbGetQuery( db , 
	"SELECT 
		loanpurpose , 
		AVG( loanamount ) AS mean_loanamount
	FROM hmda_2015 
	GROUP BY loanpurpose" 
)
dbGetQuery( db , 
	"SELECT 
		actiontype , 
		COUNT(*) / ( SELECT COUNT(*) FROM hmda_2015 ) 
			AS share_actiontype
	FROM hmda_2015 
	GROUP BY actiontype" 
)
dbGetQuery( db , "SELECT SUM( loanamount ) FROM hmda_2015" )

dbGetQuery( db , 
	"SELECT 
		loanpurpose , 
		SUM( loanamount ) AS sum_loanamount 
	FROM hmda_2015 
	GROUP BY loanpurpose" 
)
RSQLite::initExtension( db )

dbGetQuery( db , 
	"SELECT 
		LOWER_QUARTILE( loanamount ) , 
		MEDIAN( loanamount ) , 
		UPPER_QUARTILE( loanamount ) 
	FROM hmda_2015" 
)

dbGetQuery( db , 
	"SELECT 
		loanpurpose , 
		LOWER_QUARTILE( loanamount ) AS lower_quartile_loanamount , 
		MEDIAN( loanamount ) AS median_loanamount , 
		UPPER_QUARTILE( loanamount ) AS upper_quartile_loanamount
	FROM hmda_2015 
	GROUP BY loanpurpose" 
)
dbGetQuery( db ,
	"SELECT
		AVG( loanamount )
	FROM hmda_2015
	WHERE race = 5 AND ethnicity = 2"
)
RSQLite::initExtension( db )

dbGetQuery( db , 
	"SELECT 
		VARIANCE( loanamount ) , 
		STDEV( loanamount ) 
	FROM hmda_2015" 
)

dbGetQuery( db , 
	"SELECT 
		loanpurpose , 
		VARIANCE( loanamount ) AS var_loanamount ,
		STDEV( loanamount ) AS stddev_loanamount
	FROM hmda_2015 
	GROUP BY loanpurpose" 
)
library(dplyr)
dplyr_db <- dplyr::src_sqlite( dbdir )
hmda_tbl <- tbl( dplyr_db , 'hmda_2015' )
hmda_tbl %>%
	summarize( mean = mean( loanamount ) )

hmda_tbl %>%
	group_by( loanpurpose ) %>%
	summarize( mean = mean( loanamount ) )
dbGetQuery( db , "SELECT COUNT(*) FROM hmda_2015" )

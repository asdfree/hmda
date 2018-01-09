if ( .Platform$OS.type == 'windows' ) memory.limit( 256000 )

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
dbSendQuery( db , 
	"CREATE FUNCTION 
		div_noerror(l DOUBLE, r DOUBLE) 
	RETURNS DOUBLE 
	EXTERNAL NAME calc.div_noerror" 
)
dbGetQuery( db , 
	"SELECT 
		actiontype , 
		div_noerror( 
			COUNT(*) , 
			( SELECT COUNT(*) FROM hmda_2015 ) 
		) AS share_actiontype
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
dbGetQuery( db , "SELECT QUANTILE( loanamount , 0.5 ) FROM hmda_2015" )

dbGetQuery( db , 
	"SELECT 
		loanpurpose , 
		QUANTILE( loanamount , 0.5 ) AS median_loanamount
	FROM hmda_2015 
	GROUP BY loanpurpose" 
)
dbGetQuery( db ,
	"SELECT
		AVG( loanamount )
	FROM hmda_2015
	WHERE race = 5 AND ethnicity = 2"
)
dbGetQuery( db , 
	"SELECT 
		VAR_SAMP( loanamount ) , 
		STDDEV_SAMP( loanamount ) 
	FROM hmda_2015" 
)

dbGetQuery( db , 
	"SELECT 
		loanpurpose , 
		VAR_SAMP( loanamount ) AS var_loanamount ,
		STDDEV_SAMP( loanamount ) AS stddev_loanamount
	FROM hmda_2015 
	GROUP BY loanpurpose" 
)
dbGetQuery( db , 
	"SELECT 
		CORR( CAST( multifamily_home AS DOUBLE ) , CAST( loanamount AS DOUBLE ) )
	FROM hmda_2015" 
)

dbGetQuery( db , 
	"SELECT 
		loanpurpose , 
		CORR( CAST( multifamily_home AS DOUBLE ) , CAST( loanamount AS DOUBLE ) )
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

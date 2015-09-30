
require(tcltk)
library(RODBC)

conn<-odbcConnect("11th_server", uid="sa", pwd="ajoumed11!@")
#sqlQuery(conn, paste("use OMOP_VOCA"))

tb<-sqlQuery(conn, paste("select * from [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] 
                           where concept_id!='' and idx>0 and Eval_stat=0", sep=""))

for(i in 1:dim(tb)[1]){
  Evaluation()  
  cat ("Press [enter] to continue, q to quit")
  Line <- readline()
  if (Line == 'q') {break}
  #tkfocus()
}



Evaluation <-function(){
  
  tb<-sqlQuery(conn, paste("select * from [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] 
                           where concept_id!='' and idx>0 and Eval_stat=0", sep=""))
  
  rslt<-sqlQuery(conn, paste("select top 1 * from [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] 
                             where concept_id!='' and idx>0 and Eval_stat=0"))
  tt <- tktoplevel()
  tkfocus(tt)
  tkwm.title(tt,"Mapping evaluation")
  
  Mapped<-sqlQuery(conn, paste("select count(*) from [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] 
                               where concept_id!='' and idx>0"))
  Evaluated<-sqlQuery(conn, paste("select count(*) from [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] 
                                  where concept_id!='' and idx>0 and Eval_stat=1"))
  rest<-Mapped-Evaluated
  
  tkgrid(tklabel(tt,text=paste("Mapped:",Mapped)),columnspan=6, pady = 10)
  tkgrid(tklabel(tt,text=paste("Evaluated:",Evaluated)),columnspan=6, pady = 10)
  tkgrid(tklabel(tt,text=paste("rest:",rest)),columnspan=6, pady = 10)
  
  fontMenu <- tkfont.create(family="times",size=15,weight="bold")
  
  tkgrid(tklabel(tt,text=paste("KCD:")), tklabel(tt,text=paste(rslt[1,2]," : ",rslt[1,3]), font = fontMenu), pady = 10)
  aa <- writeClipboard(as.character(rslt[1,2]))
  tkgrid(tklabel(tt,text=paste("OMOP:")), tklabel(tt,text=paste(rslt[1,4]," : ",rslt[1,5]), font = fontMenu), pady = 10)
  
  
  Correct <- function()
  {     
    sqlQuery(conn, paste("update [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] set Eval_stat=1 where idx=",tb[1,1], sep=""))
    sqlQuery(conn, paste("update [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] set Correct=1 where idx=",tb[1,1], sep=""))
    tkdestroy(tt)
  }
  
  Incorrect <- function()
  {
    sqlQuery(conn, paste("update [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] set Eval_stat=1 where idx=",tb[1,1], sep=""))
    sqlQuery(conn, paste("update [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] set Correct=0 where idx=",tb[1,1], sep=""))
    tkdestroy(tt)
  }
  
  Next <-function()
  {
    sqlQuery(conn, paste("update [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] set Eval_stat=1 where idx=",tb[1,1], sep=""))
    sqlQuery(conn, paste("update [OMOP_Mapping].[dbo].[KCD_OMOP_mapping_test] set Correct=2 where idx=",tb[1,1], sep=""))
    tkdestroy(tt)
  }
  
  Correct.but <- tkbutton(tt,text="Correct",command=Correct)
  Incorrect.but <- tkbutton(tt,text="Incorrect",command=Incorrect)
  Next.but <- tkbutton(tt,text="Next",command=Next)
  
  tkgrid(Correct.but, Incorrect.but, Next.but, pady= 10, padx= 10)
  tkfocus(tt)
}

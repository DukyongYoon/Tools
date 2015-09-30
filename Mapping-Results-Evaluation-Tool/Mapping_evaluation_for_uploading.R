
library(tcltk)
library(RODBC)

conn<-odbcConnect("DB name", uid="user id", pwd="your password")
#use your own database information to connect

Table_name<-"Your table name"
#Use your table name
#Following columns are required to be conducted
#index, source code, source code name, concept id, concept name, evaluation status (0 or 1), Correct (Null, 0 or 1)
#Make name of above columns as follows:
#"idx", "source_code", "source_code_name", concept_id", "CONCEPT_NAME", "Eval_stat", "Correct" 

tb<-sqlQuery(conn, paste("select * from ",Table_name," where concept_id!='' and idx>0 and Eval_stat=0", sep=""))



for(i in 1:dim(tb)[1]){
  Evaluation()  
  cat ("Press [enter] to continue, q to quit")
  Line <- readline()
  if (Line == 'q') {break}
  #tkfocus()
}



Evaluation <-function(){
  
  tb<-sqlQuery(conn, paste("select * from ",Table_name," 
                           where concept_id!='' and idx>0 and Eval_stat=0", sep=""))
  
  rslt<-sqlQuery(conn, paste("select top 1 * from ",Table_name," 
                             where concept_id!='' and idx>0 and Eval_stat=0"))
  tt <- tktoplevel()
  tkfocus(tt)
  tkwm.title(tt,"Mapping evaluation")
  
  Mapped<-sqlQuery(conn, paste("select count(*) from ",Table_name," 
                               where concept_id!='' and idx>0"))
  Evaluated<-sqlQuery(conn, paste("select count(*) from ",Table_name," 
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
    sqlQuery(conn, paste("update ",Table_name," set Eval_stat=1 where idx=",tb[1,1], sep=""))
    sqlQuery(conn, paste("update ",Table_name," set Correct=1 where idx=",tb[1,1], sep=""))
    tkdestroy(tt)
  }
  
  Incorrect <- function()
  {
    sqlQuery(conn, paste("update ",Table_name," set Eval_stat=1 where idx=",tb[1,1], sep=""))
    sqlQuery(conn, paste("update ",Table_name," set Correct=0 where idx=",tb[1,1], sep=""))
    tkdestroy(tt)
  }
  
  Next <-function()
  {
    sqlQuery(conn, paste("update ",Table_name," set Eval_stat=1 where idx=",tb[1,1], sep=""))
    sqlQuery(conn, paste("update ",Table_name," set Correct=2 where idx=",tb[1,1], sep=""))
    tkdestroy(tt)
  }
  
  Correct.but <- tkbutton(tt,text="Correct",command=Correct)
  Incorrect.but <- tkbutton(tt,text="Incorrect",command=Incorrect)
  Next.but <- tkbutton(tt,text="Next",command=Next)
  
  tkgrid(Correct.but, Incorrect.but, Next.but, pady= 10, padx= 10)
  tkfocus(tt)
}

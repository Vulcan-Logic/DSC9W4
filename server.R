#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

shinyServer(function(input, output){

  #using fixed data    
  allYears<-seq(2010,2016,1)
  usa<-c(14964,15518,16155,16692,17393,18121,18624)
  uk<-c(2441,2620,2662,2740,3023,2886,2648)
  canada<-c(1613,1789,1824,1843,1793,1553,1530)
  aust<-c(1143,1391,1538,1567,1460,1345,1205)
  nz<-c(147,168,176,191,201,176)
  countries<-data.frame(cbind(allYears,usa,uk,canada,aust,nz))
  
  getYearsData<-reactive({
    yearsStart<-input$years[1]
    yearsEnd<-input$years[2]
    startIndx<-match(yearsStart,allYears)
    endIndx<-match(yearsEnd,allYears)
    indxSeq<-seq(startIndx,endIndx,1)
    return(indxSeq)
  })

  getDataMatrix<-reactive({
    cntry_ndx1<-input$usa
    cntry_ndx2<-input$uk
    cntry_ndx3<-input$can
    cntry_ndx4<-input$aus
    cntry_ndx5<-input$nz
    data_col_indx<-which(cbind(TRUE,cntry_ndx1,cntry_ndx2,cntry_ndx3,
                               cntry_ndx4,cntry_ndx5))
    data_row_indx<-getYearsData()
    return(data.frame(countries[data_row_indx,data_col_indx]))
  })
  
  output$frame<-renderUI({
    return(tags$iframe(seamless="seamless",
                src="document.html", 
                height=475, width=900))
  })

  output$msg<-renderText({
    #check dimensions of countries selected 
    data_mat<-getDataMatrix()
    dims<-dim(data_mat)
    if (dims[2]==1){
      return("NO COUNTRIES SELECTED")
    } 
  })

  output$plot <- renderPlotly({
    #set global options
    data_mat<-getDataMatrix()
    dims<-dim(data_mat)
    ytitle<-"GDP in Billions of USD"
    show(input$select)      
    #format the columns of the data matrix
    if (dims[2]>1){
       if (input$select=="Trillions(USD)"){
        for (i in 2:dims[2]){
          data_mat[,i]=round(data_mat[,i]/1000)
          ytitle<-"GDP in Trillions of USD"
        }
      }
      else if (input$select=="% of US-GDP"){
        ytitle<-"GDP as % of US GDP"
        usindx<-NULL
        for(i in 1:dims[1]){
          indx<-match(data_mat[i,1],allYears)
          usindx<-c(usindx,usa[indx])
        }
        if (dims[2]==2){
          data_mat[,2]=round((data_mat[,2]/usindx)*100)
        }
        else {
          for (i in (2:dims[2])){
            data_mat[,i]=round((data_mat[,i]/usindx)*100)
          }
        }
      }
    #construct the plots check for radio options     
      if (input$barType=="Bar"){
        plot1 <- plot_ly(data=data_mat, x = data_mat[,1], y=data_mat[,2],
                         type = 'bar', 
                         name = toupper(colnames(data_mat)[2]))
        if (dims[2]>2){
          for (i in (3:dims[2])){
            plot1<-plot1 %>% 
              add_trace(y = data_mat[,i], name = toupper(colnames(data_mat))[i]) 
          }
        }
        plot1<-plot1 %>% layout(
          title = "GDP of various English speaking countries",
          xaxis = list(title = "Year"),
          yaxis = list (title = ytitle))
      }
      else{
        plot1<-plot_ly(data=data_mat,x=data_mat[,1],y=data_mat[,2], 
                       name=toupper(colnames(data_mat)[2]), 
                       type="scatter", 
                       mode="lines+markers",
                       line = list(width = 4)) 
        if (dims[2]>2){
          for (i in (3:dims[2])){
            plot1<-plot1 %>% 
              add_trace(y = data_mat[,i], 
                        name = toupper(colnames(data_mat))[i], 
                        mode="lines+markers",
                        line = list(width = 4)) 
          }
        }
        plot1<-plot1 %>% layout(
          title = "GDP of various English speaking countries",
          xaxis = list(title = "Year"),
          yaxis = list (title = ytitle))
      }
      return(plot1)
    }
    else return(NULL)
  })
})

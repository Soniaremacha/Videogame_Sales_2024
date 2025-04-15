library(shiny)
library(shinyjs)
library(ggplot2)
library(dplyr)

# Cargar datos
data <- read.csv("Videogame_Sales_2024.csv")

# Convertir chr a factor
data[] <- lapply(data, function(col) {
  if (is.character(col)) factor(col) else col
})

# Sacar año
data$year <- as.integer(substr(data$release_date, 1, 4))

# Interfaz
ui <- navbarPage("Videogame Sales 2024",
  
  #############################################################################################################################################  
  # -Visualizaciones interactivas-
  tabPanel("Visualizaciones interactivas",
    mainPanel(
      tabsetPanel(
        # -------------------------------------------------------------------------------------------------------------------------------------
        # Tab 1
        tabPanel("Ventas consola", 
          h1("Ventas por consola"),
          sidebarLayout(
            sidebarPanel(
              selectInput("console_choice", "Consola:", choices = NULL),
              selectInput("region_choice", "Región:",
                          choices = c("Norteamérica" = "na_sales", 
                                      "Europa" = "pal_sales", 
                                      "Japón" = "jp_sales", 
                                      "Otros" = "other_sales",
                                      "Global" = "total_sales")
              ) # End selectInput
            ), # End sidebarPanel
           
            mainPanel(
               plotOutput("sales_trend")
            ) # End mainPanel
            
          ) # End sidebarLayout
                 
        ), # End tabPanel 1
                       
        
               
        # -------------------------------------------------------------------------------------------------------------------------------------
        # Tab 2
        tabPanel("Géneros consola", 
          h1("Popularidad de géneros por consola"),
          sidebarLayout(
            sidebarPanel(
              selectInput("console_choice2", "Consola:", choices = NULL)
            ), # End sidebarPanel
           
            mainPanel(
              plotOutput("genre_popularity")
            ) # End mainPanel
           
          ) # End sidebarLayout
        
        ), # End tabPanel 2
              
        
                        
        # -------------------------------------------------------------------------------------------------------------------------------------
        # Tab 3
        tabPanel("Top 10 videojuegos", 
          h1("Top 10 videojuegos con mejores críticas en un rango de tiempo"),
                 
          sidebarLayout(
            sidebarPanel(
              sliderInput("year_range", "Rango de años:",
                          min = 1980, max = 2025,
                          value = c(2000, 2010), 
                          sep = "", 
                          step = 1
              ) # End selectInput
            ), # End sidebarPanel
           
            mainPanel(
              plotOutput("top_games_chart")
            ) # End mainPanel
            
          ) # End sidebarLayout
          
        ), # End tabPanel 3
                 
               
              
        # -------------------------------------------------------------------------------------------------------------------------------------
        # Tab 4
        tabPanel("Heatmap ventas", 
          h1("Heatmap de ventas por consola y género"),
          
          sidebarLayout(
            sidebarPanel(
              selectInput("console_genre_choice", "Selecciona:",
                         choices = c("Consola" = "console",
                                     "Género" = "genre"))
            ), # End sidebarPanel
           
            mainPanel(
              plotOutput("sales_heatmap")
            ) # End mainPanel
            
          ) # End sidebarLayout
                 
        ), # End tabPanel 4
  
        
        
      ) # End tabsetPanel -Visualizaciones interactivas-
      
    ) # End mainPanel -Visualizaciones interactivas-
    
  ), # End tabPanel -Visualizaciones interactivas-
  
  
  
  #############################################################################################################################################
  # -Visualizaciones animadas-
  tabPanel("Visualizaciones animadas",
    mainPanel(
      tabsetPanel(
        # -------------------------------------------------------------------------------------------------------------------------------------
        # Tab 1
        tabPanel("KPI ventas",
          h1("Evolución de ventas a lo largo del tiempo"),
            sliderInput(
                      "animation", "Seleccionar año:",
                       min = min(data$year, na.rm = TRUE),
                       max = max(data$year, na.rm = TRUE),
                       value = min(data$year, na.rm = TRUE),
                       step = 1,
                       animate = animationOptions(interval = 500, loop = TRUE)  
            ),
          
            # Mostrar KPI
            tags$h2(textOutput("totalVentasTexto"), style = "color: #2c3e50; font-weight: bold;")
                 
        ), # End tabPanel 1
        # -------------------------------------------------------------------------------------------------------------------------------------
        # Tab 2
        tabPanel("Top publishers",
                 h1("Top 10 publishers por año"),
                   mainPanel(
                     imageOutput("publisher_race_chart")
                   )
        ),  # End tabPanel 2
        
        

        # -------------------------------------------------------------------------------------------------------------------------------------
        # Tab 3
        tabPanel("Visualización animada 3",
                 h1("Visualización animada 3"),
                     
                     
                     
                     
                     
                     
                     
        ) # End tabPanel 3
            
        
      ) # End TabsetPanel -Visualizaciones animadas-
             
    ), # End MainPanel -Visualizaciones animadas-

  ), # End Tabpanel -Visualizaciones animadas-
  
  
  ############################################################################################################################################# 
  # Footer
  tags$footer(
    style = "position: fixed; bottom: 0; width: 100%; text-align: center; padding: 10px; background-color: #f1f1f1;",
    useShinyjs(),
    actionButton("ir_a_web", "Acerca del dataset")
  
  ) # End Footer

) # End navbarPage

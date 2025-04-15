
packages <- c("gganimate", "gifski", "transformr")
to_install <- packages[!packages %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) install.packages(to_install)



library(gganimate)
library(gifski)
library(shiny)
library(shinyjs)
library(ggplot2)
library(dplyr)

# Cargar los datos
data <- read.csv("Videogame_Sales_2024.csv")

# Extraer year de release_date
data$year <- as.integer(substr(data$release_date, 1, 4))


function(input, output, session) {
  
  #############################################################################################################################################
  # -Visualizaciones interactivas-
  
  # -------------------------------------------------------------------------------------------------------------------------------------
  # Tab 1: Ventas consola

  # Observer de selectInput
  observe({
    # Query para la consola
    console_sales <- data %>%
      group_by(console) %>%
      summarise(total_sales = sum(total_sales, na.rm = TRUE)) %>%
      arrange(desc(total_sales))  
    
    # Actualizar selectInput de consolas
    updateSelectInput(session, "console_choice",
                      choices = console_sales$console)
  })
  
  # Nombres región
  region_names <- c("na_sales" = "Norteamérica", 
                    "pal_sales" = "Europa", 
                    "jp_sales" = "Japón", 
                    "other_sales" = "Otros", 
                    "total_sales" = "Global")
  
  
  # Filtrar choices
  output$sales_trend <- renderPlot({
    req(input$console_choice)  
    req(input$region_choice)  
    
    # Filtrar por consola y región
    filtered_data <- data %>% 
      filter(console == input$console_choice) %>%
      select(year, console, input$region_choice) %>%
      rename(total_sales = input$region_choice)
    
    # Agrupar los datos por año y sumar las ventas para cada año
    yearly_sales <- filtered_data %>%
      group_by(year) %>%
      summarise(total_sales = sum(total_sales, na.rm = TRUE)) %>%
      mutate(year = as.factor(year))
    
    # Gráfico de líneas
    ggplot(yearly_sales, aes(x = year, y = total_sales)) +
      geom_line(group = 1, color = "#BF3131", size = 1) +
      labs(title = paste("Evolución de ventas por año para", input$console_choice, "en", region_names[input$region_choice]),
           x = "Año",
           y = "Total ventas") +
      theme_minimal()
  })
  
  
  
  
  
  
  
  # -------------------------------------------------------------------------------------------------------------------------------------
  # Tab 2: Distribución géneros
  
  # Observer de selectInput
  observe({
    console_order <- data %>%
      group_by(console) %>%
      summarise(n_juegos = n()) %>%
      arrange(desc(n_juegos)) %>%
      pull(console)
    
    updateSelectInput(session, "console_choice2", choices = console_order)
  })
  
  output$genre_popularity <- renderPlot({
    req(input$console_choice2)
    
    
    # Query
    genre_counts <- data %>%
      filter(console == input$console_choice2) %>%
      group_by(genre) %>%
      summarise(count = n()) %>%
      arrange(desc(count))
    
    # Gráfico
    ggplot(genre_counts, aes(x = reorder(genre, count), y = count)) +
      geom_col(fill = "#7D0A0A") +
      coord_flip() +
      labs(title = paste("Popularidad de géneros en", input$console_choice2),
           x = "Género",
           y = "Cantidad de Videojuegos") +
      theme_minimal()
  })
  
  
  
  
  
  
  
  # -------------------------------------------------------------------------------------------------------------------------------------
  #Tab 3: Top 10 videojuegos más vendidos
  
    # Preparación de year
  data <- data %>%
    mutate(year = suppressWarnings(as.numeric(as.character(year)))) %>%
    filter(!is.na(year))         
  
  output$top_games_chart <- renderPlot({
    req(input$year_range)  
    
    # Filtrar por rango de años
    filtered_data <- data %>%
      filter(year >= input$year_range[1], year <= input$year_range[2])
    
    # Validar datos
    validate(
      need(nrow(filtered_data) > 0, "No hay datos disponibles en este rango de años.")
    )
    
    # Query Top 10 
    top_games <- filtered_data %>%
      group_by(title) %>%  
      summarise(critic_score = mean(critic_score, na.rm = TRUE)) %>%
      arrange(desc(critic_score)) %>%
      slice_head(n = 10)
    
    # Gráfico de barras
    ggplot(top_games, aes(x = reorder(title, critic_score), y = critic_score, fill = critic_score)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = round(critic_score, 1)), hjust = -0.1, size = 3) +
      labs(
        title = paste("Top 10 Juegos con mejores críticas (", input$year_range[1], "-", input$year_range[2], ")"),
        x = "Videojuego", 
        y = "Puntuación de las críticas",
        fill = "Puntuación"
      ) +
      scale_fill_gradientn(colors = c("#EAD196", "#BF3131", "#7D0A0A")) +
      coord_flip(ylim = c(5, 10)) +  # ✅ Se recorta visualmente sin cambiar el orden de los ejes
      theme_minimal() +
      theme(
        legend.position = "right",
        axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        plot.title = element_text(hjust = 0.5)
      )
    
    
    
  })
  
  
  
  
  
  
  # -------------------------------------------------------------------------------------------------------------------------------------
  # Tab 4: Heatmap de ventas
  
  output$sales_heatmap <- renderPlot({
    req(input$console_genre_choice)
    
    # Variable dinámica (console o genre)
    console_genre_choice <- input$console_genre_choice
    
    # Query Top 10
    console_genre_top <- data %>%
      group_by(.data[[console_genre_choice]]) %>%
      summarise(total_sales = sum(total_sales, na.rm = TRUE)) %>%
      arrange(desc(total_sales)) %>%
      slice_head(n = 10) %>%
      pull(1)
    
    # Filtrar dataset al top 10 y agrupar por year + console_genre_choice
    heatmap_data <- data %>%
      filter(.data[[console_genre_choice]] %in% console_genre_top) %>%
      group_by(.data[[console_genre_choice]], year) %>%
      summarise(total_sales = sum(total_sales, na.rm = TRUE), .groups = "drop") %>%
      rename(console_genre_value = 1)
    
    # Reordenar console_genre_value por total de ventas acumuladas para ordenarlo en el gráfico
    console_genre_order <- heatmap_data %>%
      group_by(console_genre_value) %>%
      summarise(total = sum(total_sales)) %>%
      arrange(desc(total)) %>%
      pull(console_genre_value)
    
    heatmap_data$console_genre_value <- factor(heatmap_data$console_genre_value, levels = console_genre_order)
    
    # Heatmap
    ggplot(heatmap_data, aes(x = year, y = console_genre_value, fill = total_sales)) +
      geom_tile(color = "white") +
      scale_fill_gradient(low = "#EAD196", high = "#BE3D2A") +
      labs(title = paste("Top 10 por Ventas – Año vs", ifelse(console_genre_choice == "console", "Consola", "Género")),
           x = "Año",
           y = ifelse(console_genre_choice == "console", "Consola", "Género"),
           fill = "Ventas Totales") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  # -------------------------------------------------------------------------------------------------------------------------------------

  
  
  
  
  
  
  
  #############################################################################################################################################
  # -Visualizaciones animadas-
  
  # -------------------------------------------------------------------------------------------------------------------------------------
  # Tab 1: KPI ventas
  output$totalVentasTexto <- renderText({
    req(input$animation)  # Asegurarse de que la animación está activada
    
    # Filtrar las ventas globales por el año seleccionado
    ventas_por_año <- data %>%
      filter(year == input$animation) %>%
      summarise(total_sales = sum(total_sales, na.rm = TRUE))
    
    # Mostrar el total de ventas como texto
    paste("Unidades vendidas globalmente en el año ", input$animation, ": ", format(ventas_por_año$total_sales, big.mark = ","), "millones")
  })
  
  
  
  # -------------------------------------------------------------------------------------------------------------------------------------
  # Tab 2: Top publishers
  
  output$publisher_race_chart <- renderImage({
    
    gif_path <- file.path("www", "race_chart.gif")
    
    # Renderiza si no está el gif en la carpeta www
    if (!file.exists(gif_path)) {
      
      # Query
      top_publishers_data <- data %>%
        group_by(year, publisher) %>%
        summarise(count = n(), .groups = "drop") %>%
        group_by(year) %>%
        mutate(max_count = max(count)) %>%
        mutate(normalized_count = count / max_count * 100) %>%
        arrange(year, desc(count)) %>%
        mutate(rank = row_number()) %>%
        filter(rank <= 10)
      
      # Race chart
      p <- ggplot(top_publishers_data,
                  aes(x = -rank, y = normalized_count, fill = publisher, group = publisher)) +
        geom_col(width = 0.8) +
        coord_flip() +
        
        # Etiquetas de publisher y cantidad de videojuegos por año 
        geom_text(aes(label = publisher), hjust = -0.1, size = 5) +
        geom_text(aes(label = sprintf("%.0f", count)), hjust = 1.1, color = "white", size = 4) + 
        
        # Cambiar ejes
        scale_x_continuous(breaks = -1:-10, labels = 1:10) +
        scale_y_continuous(labels = scales::percent_format(scale = 1)) +
        
        # Títulos, tema y leyenda
        labs(title = 'Top 10 publishers por año: {closest_state}', 
             subtitle = "(Tamaño de las barras relativo al top 1, mostrando la cantidad de videojuegos lanzados en la etiqueta)",
             x = "", 
             y = "Porcentaje de videojuegos lanzados por año relativo al top 1") +
        theme_minimal() +
        theme(legend.position = "none",
              plot.title = element_text(size = 16, face = "bold"),
              plot.subtitle = element_text(size = 12)) +
        
        # Movimiento race chart
        transition_states(year, transition_length = 4, state_length = 1) +
        ease_aes("cubic-in-out")
      
      # Guardar animación en carpeta www
      animate_plot <- animate(p, width = 800, height = 600, fps = 30, duration = 120)
      anim_save(gif_path, animation = animate_plot)
    }
    
    # Cargar el gif guardado
    list(src = gif_path, contentType = 'image/gif')
    
  }, deleteFile = FALSE)
  
  
  
  
  
  # -------------------------------------------------------------------------------------------------------------------------------------
  # Footer: Acerca del dataset
  observeEvent(input$ir_a_web, {
    runjs('window.location.href = "https://www.vgchartz.com/methodology.php";')
  })
  # -------------------------------------------------------------------------------------------------------------------------------------
  
  
  
}

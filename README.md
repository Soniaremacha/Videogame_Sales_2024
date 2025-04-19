# 🎮 Videogame Sales 2024 - Shiny Dashboard

An interactive Shiny app designed to explore global video game sales from 1971 to 2024. This dashboard allows users to visualize trends in game sales by genre, platform, publisher, and region.

## 📊 Features

3 main tabs with interactive visualizations, animated visualizations, and a world map.
  - **Interactive visualizations**: All visualizations that require input from the user.
      - *Console sales*: User can choose to input both console and region to explore sales data yearly.
      - *Console genres*: User can choose to input console to explore quantity of videogames released per genre in that console.
      - *Top 10 videogames*: User can choose a range of time to explore the top 10 videogames with best rating along the years.
      - *Sales Heatmap*: User can choose between console and genre to see the best performing console or genre in sales along the years.
        
  - **Animated visualizations**: All visualizations that show movement.
      - *Sales KPI*: User can press play and the total sales KPI will show on screen for the current year.
      - *Top publishers*: User will see a generated race chart of the publishers that launched more videogames for the current year.
        
  - **Map**: Generated world map that shows all sales recorded regionally until 2024.

## 🧰 Built With

- **R** – Statistical computing
- **Shiny** – Web application framework for R
- **ggplot2** – Elegant data visualization
- **dplyr / tidyr** – Data wrangling
- **plotly** – Interactive charts

## 📁 Project Structure

Videogame_Sales_2024/
├── server.R                # Shiny app server

├── ui.R                    # Shiny app ui

├── www/                    # Gif generated

│   └── race_chart.gif      

├── mundo.rds               # File generated from Natural Earth library for the world map

├── sales_map.png           # Image generated

└── README.md               # This file


## 📊 Dataset

The app uses the dataset [Video Game Sales 2024 - Kaggle](https://www.kaggle.com/datasets/hosammhmdali/video-game-sales-2024) (used as `Videogame_Sales_2024.csv` here), which contains:

- **Name** – Name of the game  
- **Console** – Platform of the game release (e.g., PS2, Xbox)  
- **Year** – Year of release (from original **release_date**)
- **Genre** – Type of game  
- **Publisher** – Publisher name  
- **Sales** – Sales across different regions (NA, EU, JP, Others, Global)

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## 📬 Contact

Project by **Sonia Remacha**  
For questions or suggestions, feel free to open an issue.

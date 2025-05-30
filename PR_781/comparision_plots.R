# Related to PR 781
# Compare the two different versions of Hector

# 0. Set Up --------------------------------------------------------------------
library(hector)
library(ggplot2)
library(dplyr)

BASE_DIR <- here::here("PR_781")

# 1. Main Chunk ----------------------------------------------------------------
# Read in the data!
new <- read.csv(file.path(BASE_DIR, "new_hector_rslts.csv"))
old <- read.csv(file.path(BASE_DIR, "old_hector_rslts.csv"))


# Let's rank the MSE between the total RF
new %>%
    rename(new_value = value) %>%
    left_join(old %>%
                  select(year, variable, value, scenario), by = join_by(year, variable, scenario)) %>%
    mutate(SE = (value - new_value)^2) %>%
    summarise(MSE = mean(SE), .by = c("scenario", "variable")) %>%
    arrange(desc(MSE)) ->
    MSE_table; MSE_table


lapply(unique(old$variable), function(var){

    new %>%
        filter(variable %in% var) ->
        new_to_plot

    old %>%
        filter(variable %in% var) ->
        old_to_plot

    MSE_table %>%
        filter(variable %in% var) %>%
        mutate(MSE = signif(MSE, digits = 3)) ->
        tb

    tbs <- lapply(split(tb, tb$variable), "[")

    df <- tibble(x = rep(Inf, length(tbs)),
                 y = rep(-Inf, length(tbs)),
                 variable = var,
                 tbl = tbs)

    ggplot() +
        geom_line(data = old_to_plot, aes(year, value, color = "old", group = scenario)) +
        geom_line(data = new_to_plot, aes(year, value, color = "new", group = scenario)) +
        facet_wrap("variable", scales = "free") +
        scale_color_manual(values = c("old" = "darkgrey", new = "red")) +
        labs(y = NULL, x = NULL) +
        theme(legend.position = "bottom", legend.title = element_blank()) +
        labs(title = var) +
        geom_table(data = df, aes(x = x, y = y, label = tbl),
                   hjust = 1, vjust = 0) ->
        plot; plot



    fname <- file.path(BASE_DIR,  paste0(var, ".png"))
    ggsave(plot, filename = fname, width = 10, height = 5.5)

})


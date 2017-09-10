function display_mice_data(data, title_of_plot)
    figure;
    plot(data, '-.');
    legends = cell(size(data, 2), 1);
    for idx = 1:size(legends, 1)
        legends{idx} = strcat('Mouse ', num2str(idx));
    end
    
    legend(legends, 'Location', 'Best');
    title(title_of_plot);
end
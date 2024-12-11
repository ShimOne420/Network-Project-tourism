clear all;
clc;

% Load the data from Excel
data = readtable('Database-Tourism.xlsx');

% Extract unique years from the data
years = unique(data.Year);

% Initialize a table to store centrality trends over time
centrality_trends = table();

% Loop through each year for time-based analysis
for year_idx = 1:length(years)
    year = years(year_idx);
    
    % Filter data for the current year
    year_data = data(data.Year == year, :);
    
    % Populate edge lists
    source_nodes = {}; % Continent sources
    target_nodes = {}; % Country destinations
    weights = [];      % Inbound flows
    
    for i = 1:height(year_data)
        source_nodes = [source_nodes; year_data.Continent{i}];
        target_nodes = [target_nodes; year_data.Country{i}];
        weights = [weights; year_data.Inbound_Flow(i)];
    end
    
    % Create the directed graph
    G = digraph(source_nodes, target_nodes, weights);
    
    % Calculate centrality measures
    in_degree_centrality = indegree(G); % Standard in-degree centrality
    closeness_centrality = centrality(G, 'incloseness', 'Cost', 1 ./ G.Edges.Weight); %closeness
    weighted_in_degree = sum(adjacency(G, 'weighted'), 1)'; % Weighted in-degree centrality
    
    % Analyze communities
    communities = conncomp(G, 'Type', 'weak');
    
    % Store centrality results for time-based trends
    centrality_trends = [centrality_trends; 
        table(year, {in_degree_centrality}, {weighted_in_degree}, {closeness_centrality}, {communities}, ...
              'VariableNames', {'Year', 'InDegree', 'WeightedDegree', 'Closeness', 'Communities'})];
    
    % Visualization for the current year
    figure;
    
    % Subplot 1: In-Degree Centrality Distribution
    subplot(4, 1, 1);
    histogram(in_degree_centrality, 'FaceColor', 'g');
    title(['In-Degree Centrality Distribution - Year ', num2str(year)]);
    xlabel('In-Degree Centrality');
    ylabel('Frequency');
    
    % Subplot 2: Weighted Degree Centrality Distribution
    subplot(4, 1, 2);
    histogram(weighted_in_degree, 'FaceColor', 'b');
    title(['Weighted In-Degree Distribution - Year ', num2str(year)]);
    xlabel('Weighted Degree Centrality');
    ylabel('Frequency');
    
    % Subplot 3: Closeness Centrality Distribution
    subplot(4, 1, 3);
    histogram(closeness_centrality, 'FaceColor', 'r');
    title(['Closeness Centrality Distribution - Year ', num2str(year)]);
    xlabel('Closeness Centrality');
    ylabel('Frequency');
    
    % Subplot 4: Community Structure Visualization
    subplot(4, 1, 4);
    h = plot(G);
    h.NodeCData = communities; % Color nodes by community
    colormap(parula);
    colorbar;
    title(['Communities in the Tourism Network - Year ', num2str(year)]);
end

% Time-Based Trend Visualization
figure;
hold on;
for year_idx = 1:length(years)
    % Plot average values for each centrality measure over time
    plot(years(year_idx), mean(centrality_trends.InDegree{year_idx}), 'g-o', 'DisplayName', 'In-Degree Centrality');
    plot(years(year_idx), mean(centrality_trends.WeightedDegree{year_idx}), 'b-o', 'DisplayName', 'Weighted Degree Centrality');
    plot(years(year_idx), mean(centrality_trends.Closeness{year_idx}), 'r-o', 'DisplayName', 'Closeness Centrality');
end
hold off;
xlabel('Year');
ylabel('Centrality Measure (Average)');
title('Time-Based Trends of Centrality Measures');
legend('show');
grid on;




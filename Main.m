clear;
clc;

% Load the data from Excel
data = readtable('Database-Tourism.xlsx');

% Prompt user to select a specific year for analysis
year = input('Enter the year for analysis: ');

% Filter data for the specific year selected by the user
year_data = data(data.Year == year, :);

% Populate edge lists for the selected year
source_nodes = year_data.Continent;
target_nodes = year_data.Country;
weights = year_data.Inbound_Flow;

% Create the directed graph for the specific year
G = digraph(source_nodes, target_nodes, weights);

% Calculate centrality measures for the selected year
in_degree_centrality = indegree(G);
out_degree_centrality = outdegree(G);
weighted_in_degree = sum(adjacency(G, 'weighted'), 1)';
betweenness_centrality = centrality(G, 'betweenness');

% Identify the nodes with the highest and lowest weighted in-degree
[~, max_idx] = max(weighted_in_degree);
[~, min_idx] = min(weighted_in_degree);
highest_weighted_node = G.Nodes.Name(max_idx);
lowest_weighted_node = G.Nodes.Name(min_idx);

% Display results for the selected year
fprintf('Analysis for the year %d:\n', year);
fprintf('Node with the highest weighted in-degree: %s\n', highest_weighted_node{1});
fprintf('Node with the lowest weighted in-degree: %s\n', lowest_weighted_node{1});

% Plot individual graphs for the selected year
figure;
histogram(in_degree_centrality, 'FaceColor', 'g');
title(['In-Degree Centrality Distribution - Year ', num2str(year)]);
xlabel('In-Degree Centrality');
ylabel('Frequency');

figure;
histogram(out_degree_centrality, 'FaceColor', 'b');
title(['Out-Degree Centrality Distribution - Year ', num2str(year)]);
xlabel('Out-Degree Centrality');
ylabel('Frequency');

figure;
histogram(weighted_in_degree, 'FaceColor', 'r');
title(['Weighted In-Degree Distribution - Year ', num2str(year)]);
xlabel('Weighted In-Degree Centrality');
ylabel('Frequency');

figure;
histogram(betweenness_centrality, 'FaceColor', 'm');
title(['Betweenness Centrality Distribution - Year ', num2str(year)]);
xlabel('Betweenness Centrality');
ylabel('Frequency');

% Plot community structure for the selected year
communities = conncomp(G, 'Type', 'weak');
figure;
h = plot(G);
h.NodeCData = communities;
colormap(jet);
colorbar;
title(['Communities in the Tourism Network - Year ', num2str(year)]);

% Time-Based Trends of Centrality Measures
unique_years = unique(data.Year);
time_based_trends = table();

for y = unique_years'
    % Filter data for the current year
    yearly_data = data(data.Year == y, :);
    
    % Populate edge lists
    yearly_source_nodes = yearly_data.Continent;
    yearly_target_nodes = yearly_data.Country;
    yearly_weights = yearly_data.Inbound_Flow;
    
    % Create the graph
    yearly_G = digraph(yearly_source_nodes, yearly_target_nodes, yearly_weights);
    
    % Calculate centrality measures
    yearly_in_degree = mean(indegree(yearly_G));
    yearly_out_degree = mean(outdegree(yearly_G));
    yearly_weighted_in_degree = mean(sum(adjacency(yearly_G, 'weighted'), 1));
    yearly_betweenness = mean(centrality(yearly_G, 'betweenness'));
    
    % Store results
    time_based_trends = [time_based_trends; table(y, yearly_in_degree, yearly_out_degree, ...
        yearly_weighted_in_degree, yearly_betweenness, 'VariableNames', ...
        {'Year', 'InDegree', 'OutDegree', 'WeightedInDegree', 'Betweenness'})];
end

% Plot Time-Based Trends
figure;
hold on;
plot(time_based_trends.Year, time_based_trends.InDegree, 'g-o', 'DisplayName', 'In-Degree Centrality');
plot(time_based_trends.Year, time_based_trends.OutDegree, 'b-o', 'DisplayName', 'Out-Degree Centrality');
plot(time_based_trends.Year, time_based_trends.WeightedInDegree, 'r-o', 'DisplayName', 'Weighted In-Degree Centrality');
plot(time_based_trends.Year, time_based_trends.Betweenness, 'm-o', 'DisplayName', 'Betweenness Centrality');
hold off;
xlabel('Year');
ylabel('Centrality Measure (Average)');
title('Time-Based Trends of Centrality Measures');
legend('show');
grid on;

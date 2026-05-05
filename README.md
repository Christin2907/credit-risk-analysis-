📊 Credit Risk Analysis & Scoring Model

This project focuses on analyzing credit risk and identifying weaknesses in loan approval decisions using SQL-based data analysis and a custom-built risk scoring model.

🎯 Objective

The goal is to detect misjudged or risky loan approvals and derive actionable insights to improve future lending decisions, making them more risk-aware and economically efficient.

🔍 Key Analyses
Exploration of borrower characteristics (age, income, employment, credit history)
Identification of high-risk segments (e.g., high debt-to-income ratios)
Analysis of default rates across different loan grades (A–G)
Detection of inconsistencies in loan approvals (e.g., low-risk grades with high actual defaults)
⚙️ Risk Scoring Model

A custom scoring system was developed based on key risk factors:

Income
Debt-to-Income Ratio
Employment Length
Credit History (past defaults)
Age (minor factor)

Each factor contributes to a total risk score, which is mapped to:

Low Risk
Medium Risk
High Risk
📈 Key Insights
Default rates increase significantly with higher debt burden and lower income
Past payment history is one of the strongest predictors of default
Existing loan grades (A–G) do not always reflect actual risk accurately
High-risk loans were frequently approved despite extremely high default probabilities
💡 Business Impact

The model allows identification of loans that:

should likely not have been approved
contributed significantly to financial loss

This enables:

better credit decision-making
improved risk pricing
reduction of avoidable losses
🛠️ Technologies Used
SQL (data analysis, feature engineering, aggregation)
Data visualization (Python / Matplotlib)
Risk modeling logic
📌 Conclusion

The project demonstrates how data-driven risk assessment can significantly improve lending decisions by identifying hidden risk patterns and reducing exposure to high-risk borrowers.

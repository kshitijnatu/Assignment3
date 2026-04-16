# ITCS-6190 Assignment 3: AWS Data Processing Pipeline

This project demonstrates an end-to-end serverless data processing pipeline on AWS. The process involves ingesting raw data into S3, using a Lambda function to process it, cataloging the data with AWS Glue, and finally, querying and visualizing the results on a dynamic webpage hosted on an EC2 instance.

## 1. Amazon S3 Bucket Structure 🪣

First, set up an S3 bucket with the following folder structure to manage the data workflow:

* **`bucket-name/`**
    * **`raw/`**: For incoming raw data files.
    * **`processed/`**: For cleaned and filtered data output by the Lambda function.
    * **`enriched/`**: For storing athena query results.

---

## 2. IAM Roles and Permissions 🔐

Create the following IAM roles to grant AWS services the necessary permissions to interact with each other securely.

### Lambda Execution Role

1.  Navigate to **IAM** -> **Roles** and click **Create role**.
2.  **Trusted entity type**: Select **AWS service**.
3.  **Use case**: Select **Lambda**.
4.  **Add Permissions**: Attach the following managed policies:
    * `AWSLambdaBasicExecutionRole`
    * `AmazonS3FullAccess`
5.  Give the role a descriptive name (e.g., `Lambda-S3-Processing-Role`) and create it.

### Glue Service Role

1.  Create another IAM role for **AWS service** with the use case **Glue**.
2.  **Add Permissions**: Attach the following policies:
    * `AmazonS3FullAccess`
    * `AWSGlueConsoleFullAccess`
    * `AWSGlueServiceRole`
3.  Name the role (e.g., `Glue-S3-Crawler-Role`) and create it.

### EC2 Instance Profile

1.  Create a final IAM role for **AWS service** with the use case **EC2**.
2.  **Add Permissions**: Attach the following policies:
    * `AmazonS3FullAccess`
    * `AmazonAthenaFullAccess`
3.  Name the role (e.g., `EC2-Athena-Dashboard-Role`) and create it.

---

## 3. Create the Lambda Function ⚙️

This function will automatically process files uploaded to the `raw/` S3 folder.

1.  Navigate to the **Lambda** service in the AWS Console.
2.  Click **Create function**.
3.  Select **Author from scratch**.
4.  **Function name**: `FilterAndProcessOrders`
5.  **Runtime**: Select **Python 3.9** (or a newer version).
6.  **Permissions**: Expand *Change default execution role*, select **Use an existing role**, and choose the **Lambda Execution Role** you created.
7.  Click **Create function**.
8.  In the **Code source** editor, replace the default code with LambdaFunction.py code for processing the raw data.

---

## 4. Configure the S3 Trigger ⚡

Set up the S3 trigger to invoke your Lambda function automatically.

1.  In the Lambda function overview, click **+ Add trigger**.
2.  **Source**: Choose **S3**.
3.  **Bucket**: Select your S3 bucket.
4.  **Event types**: Choose **All object create events**.
5.  **Prefix (Required)**: Enter `raw/`. This ensures the function only triggers for files in this folder.
6.  **Suffix (Recommended)**: Enter `.csv`.
7.  Check the acknowledgment box and click **Add**.

--- 
**Start Processing of Raw Data**: Now upload the Orders.csv file into the `raw/` folder of the S3 Bucket. This will automatically trigger the Lambda function.
---

## 5. Create a Glue Crawler 🕸️

The crawler will scan your processed data and create a data catalog, making it queryable by Athena.

1.  Navigate to the **AWS Glue** service.
2.  In the left pane, select **Crawlers** and click **Create crawler**.
3.  **Name**: `orders_processed_crawler`.
4.  **Data source**: Point the crawler to the `processed/` folder in your S3 bucket.
5.  **IAM Role**: Select the **Glue Service Role** you created earlier.
6.  **Output**: Click **Add database** and create a new database named `orders_db`.
7.  Finish the setup and run the crawler. It will create a new table in your `orders_db` database.

---

## 6. Query Data with Amazon Athena 🔍

Navigate to the **Athena** service. Ensure your data source is set to `AwsDataCatalog` and the database is `orders_db`. You can now run SQL queries on your processed data.

**Queries to be executed:**
* **Total Sales by Customer**: Calculate the total amount spent by each customer.
* **Monthly Order Volume and Revenue**: Aggregate the number of orders and total revenue per month.
* **Order Status Dashboard**: Summarize orders based on their status (`shipped` vs. `confirmed`).
* **Average Order Value (AOV) per Customer**: Find the average amount spent per order for each customer.
* **Top 10 Largest Orders in February 2025**: Retrieve the highest-value orders from a specific month.

---

## 7. Launch the EC2 Web Server 🖥️

This instance will host a simple web page to display the Athena query results.

1.  Navigate to the **EC2** service and click **Launch instance**.
2.  **Name**: `Athena-Dashboard-Server`.
3.  **Application and OS Images**: Select **Amazon Linux 2023 AMI**.
4.  **Instance type**: Choose **t2.micro** (Free tier eligible).
5.  **Key pair (login)**: Create and download a new key pair. **Save the `.pem` file!**
6.  **Network settings**: Click **Edit** and configure the security group:
    * **Rule 1 (SSH)**: Type: `SSH`, Port: `22`, Source: `My IP`.
    * **Rule 2 (Web App)**: Click **Add security group rule**.
        * Type: `Custom TCP`
        * Port Range: `5000`
        * Source: `Anywhere` (`0.0.0.0/0`)
7.  **Advanced details**: Scroll down and for **IAM instance profile**, select the **EC2 Instance Profile** you created.
8.  Click **Launch instance**.

---

## 8. Connect to Your EC2 Instance

1.  From the EC2 dashboard, select your instance and copy its **Public IPv4 address**.
2.  Open a terminal or SSH client and connect using your key pair:

    ```bash
    ssh -i /path/to/your-key-file.pem ec2-user@YOUR_PUBLIC_IP_ADDRESS
    ```

---

## 9. Set Up the Web Environment

Once connected via SSH, run the following commands to install the necessary software.

1.  **Update system packages**:
    ```bash
    sudo yum update -y
    ```
2.  **Install Python and Pip**:
    ```bash
    sudo yum install python3-pip -y
    ```
3.  **Install Python libraries (Flask & Boto3)**:
    ```bash
    pip3 install Flask boto3
    ```

---

## 10. Create and Configure the Web Application

1.  Create the application file using the `nano` text editor:
    ```bash
    nano app.py
    ```
2.  Copy and paste your Python web application code (`EC2InstanceNANOapp.py`) into the editor.

3.  ‼️ **Important**: Update the placeholder variables at the top of the script:
    * `AWS_REGION`: Your AWS region (e.g., `us-east-1`).
    * `ATHENA_DATABASE`: The name of your Glue database (e.g., `orders_db`).
    * `S3_OUTPUT_LOCATION`: The S3 URI for your Athena query results (e.g., `s3://your-athena-results-bucket/`).

4.  Save the file and exit `nano` by pressing `Ctrl + X`, then `Y`, then `Enter`.

---

## 11. Run the App and View Your Dashboard! 🚀

1.  Execute the Python script to start the web server:
    ```bash
    python3 app.py
    ```
    You should see a message like `* Running on http://0.0.0.0:5000/`.

2.  Open a web browser and navigate to your instance's public IP address on port 5000:
    ```
    http://YOUR_PUBLIC_IP_ADDRESS:5000
    ```
    You should now see your Athena Orders Dashboard!

---

## Important Final Notes

* **Stopping the Server**: To stop the Flask application, return to your SSH terminal and press `Ctrl + C`.
* **Cost Management**: This setup uses free-tier services. To prevent unexpected charges, **stop or terminate your EC2 instance** from the AWS console when you are finished.

---

## Approach and Explanations

### Overall approach

This solution follows a simple event-driven architecture where each AWS service handles one clear responsibility:

1. **Ingest**: Raw order CSV files are uploaded into `raw/` in S3.
2. **Transform**: A Lambda function is triggered by S3 object creation events, filters/cleans data, and writes output to `processed/`.
3. **Catalog**: AWS Glue crawler scans the `processed/` folder and updates schema metadata in `orders_db`.
4. **Analyze**: Athena runs SQL directly on cataloged S3 data, and writes query results to `enriched/`.
5. **Visualize**: A Flask app running on EC2 executes Athena queries and renders results in HTML tables.

This approach was chosen because it is modular, serverless for core data processing, and easy to scale without tightly coupling ingestion, processing, and reporting.

### Stage-by-stage explanation

- **S3 structure (`raw/`, `processed/`, `enriched/`)**: Separates lifecycle stages of data so it is easy to track source data, transformed data, and analytics output.
- **IAM roles**: Uses least-privilege role separation (Lambda, Glue, EC2) so each service only gets the permissions it needs.
- **Lambda trigger pattern**: New files in `raw/` automatically invoke processing, removing manual orchestration.
- **Glue crawler + Data Catalog**: Eliminates manual schema management and keeps Athena table metadata synchronized with processed data.
- **Athena over S3**: Enables SQL analytics without provisioning or managing a database server.
- **EC2 + Flask dashboard**: Provides a lightweight, real-time presentation layer for query outputs.

### Query approach and purpose

The dashboard includes five business-oriented queries, each designed to answer a specific analytical question:

1. **Total Sales by Customer**  
   Aggregates `SUM(Amount)` by customer to identify top revenue contributors.

2. **Monthly Order Volume and Revenue**  
   Groups by `DATE_TRUNC('month', OrderDate)` to analyze seasonality and month-over-month business activity.

3. **Order Status Dashboard**  
   Summarizes order counts and value by status to monitor fulfillment pipeline health.

4. **Average Order Value (AOV) per Customer**  
   Uses `AVG(Amount)` to compare customer purchasing behavior and detect high-value accounts.

5. **Top 10 Largest Orders in February 2025**  
   Filters a specific time window and ranks by `Amount` to quickly surface high-impact transactions.

### Operational notes and assumptions

- The Athena database is `orders_db` and the table queried by the web app is `processed`.
- The S3 location configured for Athena query output is `s3://6190assignment3bucket/processed/`.
- For production use, you should usually store Athena query output in a separate prefix (for example `enriched/`) to avoid mixing transformed source data and query result files.

---

## Screenshots

Console captures for key setup steps are saved under `outputs/output-screenshots/`.

### S3 bucket folder structure

![S3 bucket folder structure showing raw, processed, and enriched prefixes](outputs/output-screenshots/Screenshot-S3-Folder-Structure.png)

### IAM roles

![IAM roles created for Lambda, Glue, and EC2](outputs/output-screenshots/Screenshot-IAM-Roles.png)

### Lambda function creation

![Lambda function creation for FilterAndProcessOrders](outputs/output-screenshots/Screenshot-Lambda-Creation.png)

### S3 trigger on the Lambda function

![S3 event trigger configured on the Lambda function for raw/ CSV uploads](outputs/output-screenshots/Screenshot-Lambda-Trigger.png)

### Processed CSV output

![Processed CSV file generated by the Lambda pipeline](outputs/output-screenshots/Screenshot-Of-Processed-CSV.png)

### Crawler and CloudWatch output

![Glue crawler run details and related CloudWatch logs](outputs/output-screenshots/Screenshot-Of-Crawler-CloudWatch.png)

### Athena query results written to enriched folder

![Athena query output files saved to the enriched folder](outputs/output-screenshots/Screenshot-Of-Athena-Query-Results-Enriched-Folder.png)

### Final dashboard (web app) views

![Athena Orders Dashboard view 1](outputs/output-screenshots/Screenshot-Of-Final-Webpage-1.png)

![Athena Orders Dashboard view 2](outputs/output-screenshots/Screenshot-Of-Final-Webpage-2.png)

![Athena Orders Dashboard view 3](outputs/output-screenshots/Screenshot-Of-Final-Webpage-3.png)

![Athena Orders Dashboard view 4](outputs/output-screenshots/Screenshot-Of-Final-Webpage-4.png)

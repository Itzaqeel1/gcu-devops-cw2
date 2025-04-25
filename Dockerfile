# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
# If you had package.json, you'd copy it first and run npm install
COPY server.js .

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Define environment variable
# ENV NAME World

# Run server.js when the container launches
CMD ["node", "server.js"]

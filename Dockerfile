# Use a lightweight Node.js image
FROM node:18-alpine

# set working directory inside the container
WORKDIR /app

# copy package.json first to install dependencies
COPY package.json ./

# Install dependencies
RUN npm install

# copy the rest of the project files
COPY . .

# Run tests by default
CMD ["npm", "test"]


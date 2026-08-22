const descriptions = {
    nginx: {
        title: "Nginx",
        description:
            "Nginx is the entry point of the infrastructure. " +
            "It handles HTTPS connections and acts as a reverse proxy " +
            "to the different services."
    },

    wordpress: {
        title: "WordPress",
        description:
            "WordPress is the content management system used by the project. " +
            "It runs in its own container and communicates with MariaDB " +
            "for database operations."
    },

    mariadb: {
        title: "MariaDB",
        description:
            "MariaDB is the database server used by WordPress. " +
            "It stores WordPress users, posts, settings and other data " +
            "inside a persistent volume."
    },

    redis: {
        title: "Redis",
        description:
            "Redis provides object caching for WordPress. " +
            "It stores frequently accessed data in memory to reduce " +
            "the number of database queries."
    },

    adminer: {
        title: "Adminer",
        description:
            "Adminer is a lightweight web interface for managing the " +
            "MariaDB database. It allows you to inspect databases, " +
            "tables and data through a browser."
    },

    ftp: {
        title: "FTP",
        description:
            "The FTP service provides file transfer access to the " +
            "WordPress files stored in the shared WordPress volume."
    },

    onlogs: {
        title: "OnLogs",
        description:
            "OnLogs provides a web interface for viewing Docker container " +
            "logs, making it easier to monitor the services running in " +
            "the infrastructure."
    }
};

const cards = document.querySelectorAll(".service-card");
const title = document.getElementById("service-title");
const description = document.getElementById("service-description");

cards.forEach(function (card) {

    card.addEventListener("click", function () {

        const service = card.dataset.service;
        const info = descriptions[service];

        title.textContent = info.title;
        description.textContent = info.description;

        cards.forEach(function (item) {
            item.classList.remove("active");
        });

        card.classList.add("active");
    });

});

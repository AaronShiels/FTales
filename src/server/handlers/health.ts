import { RequestHandler } from "express";

const handler: RequestHandler<{}, string> = (_, response) => {
	response.send("Healthy");
};

export { handler };

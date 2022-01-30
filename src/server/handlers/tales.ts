import { RequestHandler } from "express";

const handler: RequestHandler<{}, string> = (_, response) => {
	const tale = "Ashley is so god damn sexy mmmmmmm!";
	response.send(tale);
};

export { handler };

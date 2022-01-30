import { FC } from "react";
import * as api from "../services/api.js";

const Main: FC = () => {
	const handleClick = async (): Promise<void> => {
		const tale = await api.getTale();
		const utterance = new SpeechSynthesisUtterance(tale);
		window.speechSynthesis.speak(utterance);
	};

	return (
		<div>
			<h1>Audio</h1>
			<button onClick={handleClick}>Play</button>
		</div>
	);
};

export default Main;

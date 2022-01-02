import * as ReactDOM from "react-dom";
import Main from "./components/Main";

declare global {
	const API_BASE_URL: string;
}

const appContainerElement = document.getElementById("app");
ReactDOM.render(<Main />, appContainerElement);

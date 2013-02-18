package org.springsource.showcases.pizzashop.web;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.roo.addon.web.mvc.controller.scaffold.RooWebScaffold;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springsource.showcases.pizzashop.domain.Pizza;


@RequestMapping("/pizzas")
@Controller
@RooWebScaffold(path = "pizzas", formBackingObject = Pizza.class)
public class PizzaController {
	
	@ResponseStatus(HttpStatus.CREATED)
	@RequestMapping(method = RequestMethod.POST, consumes = "application/json", produces = "application/json")
	public @ResponseBody Pizza createFromJson(@RequestBody Pizza pizza) {
		pizza.persist();
		return Pizza.findPizza(pizza.getId());
	}

	@RequestMapping(value = "/{id}", produces = "application/json")
	public @ResponseBody Pizza showJson(@PathVariable("id") Long id) {
		return Pizza.findPizza(id);
	}
	
	@RequestMapping(produces = "application/json")
	public @ResponseBody List<Pizza> listJson(@RequestParam(value = "page", required = false) Integer page, @RequestParam(value = "size", required = false) Integer size) {
		return getPizzas(page, size);
	}
	
	@RequestMapping(method = RequestMethod.PUT, consumes = "application/json", produces = "application/json")
	public @ResponseBody Pizza updateJson(@RequestBody Pizza pizza) {
		pizza.merge();
		return Pizza.findPizza(pizza.getId());
	}

	@RequestMapping(value = "/{id}", method = RequestMethod.DELETE, produces = "application/json")
	public @ResponseBody List<Pizza> deleteJson(@PathVariable("id") Long id, @RequestParam(value = "page", required = false) Integer page,
			@RequestParam(value = "size", required = false) Integer size) {
		Pizza pizza = Pizza.findPizza(id);
		pizza.remove();
		return getPizzas(page, size);
	}


	// helpers

	private List<Pizza> getPizzas(Integer page, Integer size) {
		if (page != null || size != null) {
			int sizeNo = size == null ? 10 : size.intValue();
			final int firstResult = page == null ? 0 : (page.intValue() - 1) * sizeNo;
			return Pizza.findPizzaEntries(firstResult, sizeNo);
//            float nrOfPages = (float) Pizza.countPizzas() / sizeNo;
//            uiModel.addAttribute("maxPages", (int) ((nrOfPages > (int) nrOfPages || nrOfPages == 0.0) ? nrOfPages + 1 : nrOfPages));
		} else {
			return Pizza.findAllPizzas();
		}
	}

}
